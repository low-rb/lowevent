# frozen_string_literal: true

module Low
  module Events
    # How many events run each second over the last minute, of every kind and every tree, kept apart or not. It counts
    # in 60 slots, one per second, reused as time goes on, so counting costs the same however busy the app gets.
    class ActionRate
      SECONDS = 60

      def initialize
        @seconds = Array.new(SECONDS)
        @counts = Array.new(SECONDS, 0)
      end

      def count(now: clock)
        second = now.floor
        slot = second % SECONDS
        reset(slot, second) unless @seconds[slot] == second
        @counts[slot] += 1
      end

      # Events a second on average over the last minute, so one busy moment doesn't make it jump.
      def per_second(now: clock)
        (last_minute(now).sum / SECONDS.to_f).round(1)
      end

      private

      def reset(slot, second)
        @seconds[slot] = second
        @counts[slot] = 0
      end

      def last_minute(now)
        second = now.floor
        (0...SECONDS).filter_map { |slot| @counts[slot] if @seconds[slot] && second - @seconds[slot] < SECONDS }
      end

      def clock
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end
