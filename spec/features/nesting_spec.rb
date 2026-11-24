# frozen_string_literal: true

require_relative '../../lib/lowevent'

class NestedEvent < LowEvent
end

# Like a request or an interval's tick.
class TreeStartingEvent < LowEvent
  def starts_event_tree?
    true
  end
end

RSpec.describe 'Nesting events' do
  let(:pool) { Low::Events::EventPool.new }
  let(:event_class) { NestedEvent }
  let(:outer) { event_class.new(key: :outer, action: :handle) }
  let(:inner) { event_class.new(key: :inner) }
  let(:after) { event_class.new(key: :after) }
  let(:observer) { Class.new { include Observers } }

  before do
    Observers::Keys.reset
    allow(Providers).to receive(:[]).with('low.event.pool').and_return(pool)
    inner_event = inner
    observer.define_singleton_method(:handle) { |event:| inner_event.trigger && event }
    observer.observe :outer, action: :handle
  end

  it 'puts an event triggered by an observer under the event it observes' do
    root = event_class.new(key: :root)
    root.trigger
    outer.trigger

    expect([root.children, outer.children]).to eq([[outer], [inner]])
  end

  it 'puts an event that happens after one has finished under the first event' do
    root = event_class.new(key: :root)
    root.trigger
    outer.trigger
    after.trigger

    expect(root.children.map(&:key)).to eq(%i[outer after])
  end

  it "times work that isn't an observer with the events it causes under it" do
    root = event_class.new(key: :root)
    root.trigger
    recorded = event_class.new(key: :work)
    result = recorded.record do
      outer.trigger
      :done
    end

    expect([result, root.children, recorded.children, recorded.milliseconds]).to match([:done, [recorded], [outer], be >= 0])
  end

  it 'only runs the work when nothing is happening to record it under' do
    recorded = event_class.new(key: :work)

    expect([recorded.record { :done }, recorded.milliseconds, pool.event_trees.size]).to eq([:done, nil, 0])
  end

  it 'starts a tree of its own each time for an event that starts one' do
    3.times { TreeStartingEvent.new(key: :tick).trigger }

    expect(pool.event_trees.values.map { |tree| tree.sequence.size }).to eq([1, 1, 1])
  end
end
