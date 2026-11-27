# frozen_string_literal: true

require 'observers'
require_relative 'branch_event'

module Low
  module Events
    class EventTree
      include Observers

      attr_reader :request_id, :root_event, :sequence
      attr_accessor :current_event

      def initialize(request_id: nil)
        @request_id = request_id
        @root_event = nil
        @current_event = nil
        @sequence = []
      end

      def branch(event:)
        @sequence << event

        if @root_event.nil?
          @root_event = event
          @current_event = event
        else
          @current_event.children << event
        end

        # Only made when something observes the tree, like the matrix's stream, as most trees have no observers.
        Observers::Keys.find(self)&.trigger(action: :branch, event: BranchEvent.new(event_tree: self, event:))
      end
    end
  end
end
