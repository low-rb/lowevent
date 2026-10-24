# frozen_string_literal: true

require 'observers'

require_relative '../events/request_event'
require_relative 'event_tree'
require_relative '../support/pool_hash'

module Low
  module Events
    class EventPool
      include Observers

      BUFFER_SIZE = 100

      def initialize
        @event_trees = Support::PoolHash.new(BUFFER_SIZE)
        @request_counts = Support::PoolHash.new(BUFFER_SIZE)
        # Guards both pools, as requests can be handled on more than one thread (like Puma or Iodine with threads).
        @mutex = Mutex.new
      end

      def current_event_tree(event:)
        event_tree, created = @mutex.synchronize do
          request_id = request_id(event:)
          next [@event_trees[request_id], false] if @event_trees[request_id]

          [@event_trees.add(request_id, EventTree.new(request_id:)), true]
        end

        # Outside the lock, as observers can do anything (including create events).
        trigger action: :new_event_tree, event: event_tree if created

        event_tree
      end

      # A copy, so it can be iterated while event trees are added.
      def event_trees
        @mutex.synchronize { @event_trees.dup }
      end

      private

      def request_id(event:)
        fiber_id = Fiber.current.object_id
        increment_request_counts(fiber_id:) if event.is_a?(RequestEvent)
        "#{fiber_id}-#{@request_counts[fiber_id]}"
      end

      def increment_request_counts(fiber_id:)
        @request_counts[fiber_id] ||= 0
        @request_counts[fiber_id] += 1
      end
    end
  end
end
