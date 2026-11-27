# frozen_string_literal: true

require_relative '../../lib/lowevent'
require_relative '../fixtures/child_event'
require_relative '../fixtures/parent_event'

RSpec.describe 'Event Tree' do
  # 1. Using numerical keys to ensure unique key/observers in each context. Could reset Observers instead before requiring parent observer.
  # 2. Currently resetting fibers per context to create a new EventTree (stores root event). Could inject 'low.event.pool' instead.
  context 'when an event happens after an event' do
    let(:parent_event) { ParentEvent.new(key: 1) }
    let(:child_event) { ChildEvent.new(key: 2) }

    before do
      allow(Fiber).to receive(:current).and_return(1)
    end

    it 'adds child event to parent event' do
      parent_event.trigger
      child_event.trigger

      expect(parent_event.children).to eq([child_event])
    end

    context 'via an observer' do
      let(:parent_event) { ParentEvent.new(key: 3, action: :handle) }

      before do
        allow(Fiber).to receive(:current).and_return(2)
        require_relative '../fixtures/parent_observer'
      end

      it 'adds child event to parent event' do
        parent_event.trigger

        expect(parent_event.children.first).to be_an_instance_of(ChildEvent)
      end
    end
  end

  describe 'a branch' do
    let(:tree) { Low::Events::EventTree.new(request_id: 'branch-spec') }
    let(:event) { ParentEvent.new(key: 'branch-spec') }

    it "isn't made into a branch event when nothing observes the tree" do
      allow(Low::Events::BranchEvent).to receive(:new).and_call_original
      tree.branch(event:)

      expect(Low::Events::BranchEvent).not_to have_received(:new)
      expect(tree.root_event).to be(event)
    end

    it 'is given to what observes the tree' do
      watcher = Class.new { def branch(event:) = (@branched ||= []) << event.event; attr_reader :branched }.new
      tree.observers << watcher
      tree.branch(event:)

      expect(watcher.branched).to eq([event])
    end
  end
end
