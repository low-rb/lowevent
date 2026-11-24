# frozen_string_literal: true

require_relative '../fixtures/mock_event'
require_relative '../fixtures/mock_observer'

# An interface that we test via an implementation.
RSpec.describe Low::Event do
  describe '#define' do
    it 'defines observers' do
      MockEvent.define do |observers|
        observers << MockObserver
      end

      expect(Observers[MockEvent]).to include(be_an_instance_of(Observers::Observer))
    end

    context 'with an instance' do
      it 'defines observers' do
        MockEvent.new.define do |observers|
          observers << MockObserver
        end
      end
    end
  end

  describe '#milliseconds' do
    it 'is nil until the event is triggered and then how long its observers took' do
      event = MockEvent.new
      before_trigger = event.milliseconds
      event.trigger

      expect([before_trigger, event.milliseconds]).to match([nil, be_a(Float).and(be >= 0)])
    end
  end
end
