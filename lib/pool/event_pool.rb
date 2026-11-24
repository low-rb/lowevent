# frozen_string_literal: true

require 'observers'

require_relative 'event_tree'
require_relative '../support/pool_hash'

module Low
  module Events
    class EventPool
      include Observers

      BUFFER_SIZE = 100
      KEPT_APART_SIZE = 20

      def initialize
        @event_trees = Support::PoolHash.new(BUFFER_SIZE)
        @kept_apart_trees = Support::PoolHash.new(KEPT_APART_SIZE)
        @request_counts = Support::PoolHash.new(BUFFER_SIZE)
        @kept_apart = nil
      end

      # Trees whose first event is internal or the block picks are kept apart in a buffer of their own like a framework's
      # own pages. They never push the app's requests out and event_trees leaves them out.
      def keep_apart(&rule)
        @kept_apart = rule
      end

      def current_event_tree(event:)
        request_id = request_id(event:)
        existing = find_event_tree(request_id)
        return existing if existing

        return @kept_apart_trees.add(request_id, EventTree.new(request_id:)) if kept_apart?(event)

        event_tree = @event_trees.add(request_id, EventTree.new(request_id:))
        trigger action: :new_event_tree, event: event_tree

        event_tree
      end

      # The tree of what's happening now on this fiber like the request being answered without starting one.
      def event_tree_now
        fiber_id = Fiber.current.object_id
        find_event_tree("#{fiber_id}-#{@request_counts[fiber_id]}")
      end

      def event_trees
        @event_trees
      end

      private

      def kept_apart?(event)
        event.internal? || @kept_apart&.call(event)
      end

      def find_event_tree(request_id)
        @event_trees[request_id] || @kept_apart_trees[request_id]
      end

      def request_id(event:)
        fiber_id = Fiber.current.object_id
        increment_request_counts(fiber_id:) if event.starts_event_tree?
        "#{fiber_id}-#{@request_counts[fiber_id]}"
      end

      def increment_request_counts(fiber_id:)
        @request_counts[fiber_id] ||= 0
        @request_counts[fiber_id] += 1
      end
    end
  end
end
