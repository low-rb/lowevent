# frozen_string_literal: true

require_relative '../../lib/lowevent'

RSpec.describe Low::Events::EventPool do
  subject(:event_pool) { described_class.new }

  def request_event = Low::Events::RequestEvent.new(request: nil)

  describe '#event_trees' do
    it 'can be iterated while event trees are added' do
      event_pool.current_event_tree(event: request_event)

      expect do
        event_pool.event_trees.each_value { event_pool.current_event_tree(event: request_event) }
      end.not_to raise_error
    end
  end

  describe '#current_event_tree' do
    it 'gives each request on each thread its own event tree' do
      threads = Array.new(8) do
        Thread.new { Array.new(50) { event_pool.current_event_tree(event: request_event).request_id } }
      end
      request_ids = threads.flat_map(&:value)

      expect(request_ids.uniq.size).to eq(8 * 50)
    end

    it 'never holds more event trees than the buffer size' do
      threads = Array.new(8) do
        Thread.new { 50.times { event_pool.current_event_tree(event: request_event) } }
      end
      threads.each(&:join)

      expect(event_pool.event_trees.size).to eq(described_class::BUFFER_SIZE)
    end
  end
end
