# frozen_string_literal: true

require_relative '../interfaces/event'

module Low
  module Events
    class RequestEvent < Event
      attr_reader :request, :response_event

      def initialize(request:, action: :request)
        super(key: self.class, action:)

        @request = request
      end

      # Takes the first observer's response, then passes the event back along its observers on the response's way out.
      # Each with a "response" method gets it, with the response in "response_event", and can add to it, like a cookie.
      def take
        @response_event = super
        Observers::Keys[@key].observers.each do |observer|
          observer.object.response(event: self) if observer.object.respond_to?(:response)
        end
        @response_event
      end
    end
  end
end
