# frozen_string_literal: true

require_relative '../interfaces/event'

module Low
  module Events
    # A request, which its first observer to respond answers. On the response's way back out, each observer it passed
    # with a "response" method gets "response(event:, result:)", with the response it took, and can add to it.
    class RequestEvent < Event
      attr_reader :request

      def initialize(request:, action: :request)
        super(key: self.class, action:, return_action: :response)

        @request = request
      end
    end
  end
end
