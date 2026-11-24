# frozen_string_literal: true

require_relative '../../lib/lowevent'

# Like a request or an interval's tick.
class PooledEvent < LowEvent
  def starts_event_tree?
    true
  end
end

RSpec.describe Low::Events::EventPool do
  subject(:pool) { described_class.new }

  before do
    Observers::Keys.reset
    allow(Providers).to receive(:[]).with('low.event.pool').and_return(pool)
  end

  it 'keeps the trees the rule picks apart from the event trees' do
    pool.keep_apart { |event| event.key == :internal }
    2.times { PooledEvent.new(key: :internal).trigger }
    PooledEvent.new(key: :app).trigger

    expect(pool.event_trees.values.map { |tree| tree.root_event.key }).to eq([:app])
  end

  it "doesn't let trees kept apart push the event trees out" do
    pool.keep_apart { |event| event.key == :internal }
    PooledEvent.new(key: :app).trigger
    (described_class::BUFFER_SIZE + 1).times { PooledEvent.new(key: :internal).trigger }

    expect(pool.event_trees.size).to eq(1)
  end

  it "keeps an internal event's tree apart without a rule" do
    tick = PooledEvent.new(key: :tick)
    allow(tick).to receive(:internal?).and_return(true)
    tick.trigger

    expect(pool.event_trees).to be_empty
  end

  it 'knows the tree being answered now on this fiber' do
    answering = []
    observer = Class.new { include Observers }
    observer.define_singleton_method(:handle) { |event:| answering << [event, Providers['low.event.pool'].event_tree_now] }
    observer.observe :app, action: :handle
    PooledEvent.new(key: :app, action: :handle).trigger

    event, tree = answering.first
    expect(tree.root_event).to be(event)
  end

  it 'nests events under a tree kept apart' do
    pool.keep_apart { |event| event.key == :internal }
    root = PooledEvent.new(key: :internal)
    root.trigger
    work = PooledEvent.new(key: :work)
    allow(work).to receive(:starts_event_tree?).and_return(false)
    work.record { :done }

    expect(root.children.map(&:object_id)).to eq([work.object_id])
  end
end
