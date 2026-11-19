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
      end

      def current_event_tree(event:)
        request_id = request_id(event:)

        return @event_trees[request_id] if @event_trees[request_id]

        event_tree = @event_trees.add(request_id, EventTree.new(request_id:))
        trigger action: :new_event_tree, event: event_tree

        event_tree
      end

      def event_trees
        @event_trees
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
