# frozen_string_literal: true

require_relative '../interfaces/event'

module Low
  module Events
    # A request, which its first observer to respond answers. On the response's way back out, each observer it passed
    # with a "response" method gets "response(event:, result:)", with the response it took, and can add to it.
    class RequestEvent < Event
      attr_reader :request, :store

      def initialize(request:, action: :request)
        super(key: self.class, action:, return_action: :response)

        @request = request
        @store = {} # What observers keep while the request's answered, for its way back out, like a cookie to set.
      end

      class << self
        # The RequestEvent being answered, for code deep in answering it, like a template, or nil outside a request.
        def current
          Providers['low.event.pool'].request_event
        end
      end
    end
  end
end
