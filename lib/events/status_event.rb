# frozen_string_literal: true

require_relative '../interfaces/event'

module Low
  module Events
    class StatusEvent < Event
      attr_reader :status, :request

      def initialize(status:, request:, key: nil, action: :render)
        super(key: key || status, action:)

        @status = status
        @request = request
      end

      # Status is a complex type that can be represented by both "Status" generically and "Status[:code]" specifically.
      class << self
        # Nodes observe "Status" or "Status[404]" rather than this class so they're who observes it.
        def observers(key = nil)
          return super if key

          Observers.of_keys { |each_key| each_key == Status || each_key.is_a?(Status::StatusCode) }
        end

        def trigger(status:, **kwargs)
          new(status:, **kwargs).trigger || new(status:, key: Status, **kwargs).trigger
        end
      end
    end
  end
end
