# frozen_string_literal: true

require_relative '../interfaces/event'

module Low
  module Events
    # A node rendering inside another like a layout or a formatter. Recording its rendering times it in the request's tree
    # with the events it causes under it. It holds the timing so the RenderEvent the node gets can stay immutable.
    class NodeEvent < Event
      def initialize(node:)
        super(key: node, action: :render)
      end
    end
  end
end
