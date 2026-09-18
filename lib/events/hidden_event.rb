# frozen_string_literal: true

require 'lowtype'

module Low
  module Events
    # An event that happens on event tree branching and isn't added to the event tree/sequence.
    class HiddenEvent
      include LowType

      attr_reader :key, :action, :created_at

      def initialize(key:, action: nil)
        @key = key
        @action = action
        @created_at = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      end

      def trigger
        event_tree = branch
        key = Observers::Keys[@key]
        key.trigger(event: self) { restore_level(event_tree:) }
      end

      class << self
        def trigger(**kwargs)
          new(**kwargs).trigger
        end

        def inherited(child)
          child.include LowType
        end
      end
    end
  end
end
