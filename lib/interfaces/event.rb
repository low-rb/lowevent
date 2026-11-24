# frozen_string_literal: true

require 'lowtype'
require 'observers'
require_relative 'definable'
require_relative '../support/value_object'

module Low
  # An event represents what is currently happening; the past, present and future.
  #
  # They are action-driven, representing inputs and outputs in a linear pipeline-like flow,
  # which end up as children of the event... which is why events are mutable (except for RenderEvent).
  # They are one-to-many with a return value.
  #
  # Integrations:
  # - Observers for observer pattern which we wrap in an event-centric API
  # - EventPool for a tree of events and their child events (defined in this gem)
  # - LowState for state machines to trigger multiple ordered actions [UNLRELEASED]
  class Event
    include LowType
    include Observers
    include Events::Definable
    include Support::ValueObject

    attr_reader :key, :action, :actions, :return_action, :created_at, :finished_at
    attr_accessor :children

    # Subclass provides a key such as "self.class".
    # Subclass defines default action or actions, but not both.
    # A return action, like :response, is called on each observer a take passed, with what it took, on its way back out.
    def initialize(key:, action: nil, actions: [], return_action: nil, children: [])
      @key = key
      @action = action
      @actions = actions
      @return_action = return_action
      @children = children

      @created_at = clock
      @finished_at = nil
    end

    def trigger
      event_tree = branch
      key = Observers::Keys[@key]
      key.trigger(event: self) { restore_level(event_tree:) }
    ensure
      @finished_at = clock
    end

    def take
      event_tree = branch
      key = Observers::Keys[@key]
      key.take(event: self, returning: @return_action) { restore_level(event_tree:) }
    ensure
      @finished_at = clock
    end

    # How long its observers took including the events they caused. It's nil until it's triggered or taken.
    def milliseconds
      finished_at - created_at if finished_at
    end

    def branch
      event_tree = Providers['low.event.pool'].current_event_tree(event: self)
      event_tree.branch(event: self)
    end

    private

    # Milliseconds with their fraction as most events take less than one.
    def clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
    end

    def restore_level(event_tree:)
      event_tree.current_event = self if event_tree.respond_to?(:current_event)
    end

    class << self
      def trigger(**kwargs) = new(**kwargs).trigger
      def take(**kwargs) = new(**kwargs).take

      def inherited(child)
        child.include LowType
        increase_count
        add_event(child)
      end

      def count
        @count ||= 0
      end

      def increase_count
        @count = count + 1
      end

      def events
        @events ||= []
      end

      def add_event(event)
        events << event
      end
    end
  end
end
