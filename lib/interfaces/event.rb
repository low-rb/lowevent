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
      run_in_tree { Observers::Keys[@key].trigger(event: self) }
    end

    def take
      run_in_tree { Observers::Keys[@key].take(event: self, returning: @return_action) }
    end

    # Times work that isn't an observer like rendering a node or running a query with the events it causes under it. It
    # joins the tree of the request or interval happening now and outside one like a query at boot it only runs the work.
    def record(&)
      return yield unless Providers['low.event.pool'].event_tree_now

      run_in_tree(&)
    end

    # Whether its tree is kept apart from the app's like an interval's tick. It's still recorded in a buffer of its own.
    def internal?
      false
    end

    # Whether it starts a tree of its own rather than joining the one happening now like a request does.
    def starts_event_tree?
      false
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

    # The event is the one happening while the block runs so events it causes go under it. Then the one before it is
    # happening again or the first event when none was.
    def run_in_tree
      event_tree = Providers['low.event.pool'].current_event_tree(event: self)
      parent = event_tree.current_event
      event_tree.branch(event: self)
      event_tree.current_event = self
      yield
    ensure
      event_tree.current_event = parent || event_tree.root_event if event_tree
      @finished_at = clock
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
