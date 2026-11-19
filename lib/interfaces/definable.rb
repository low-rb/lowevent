# frozen_string_literal: true

module Low
  module Events
    module Definable
      # Yields the event's observers to add to. A block that returns a list puts them in that order, so an observer can
      # go first: "observers = [MyLogger, *observers]".
      def define(key = self)
        observers = observers(key)
        list = yield observers
        observers.replace(list) if list.is_a?(Array)
      end

      class << self
        def included(klass)
          klass.extend Definable
        end
      end
    end
  end
end
