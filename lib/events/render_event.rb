# frozen_string_literal: true

module Low
  module Events
    # Params and the request are carried over from the RouteEvent so that every node rendered for a route can access them.
    RenderEvent = Data.define(:action, :props, :params, :request) do
      # TODO: Duplicate props when used in a parallelized situation (antlers: "<{ :parallelize }>")
      def initialize(action: :render, props: {}, params: {}, request: nil)
        super
      end
    end
  end
end
