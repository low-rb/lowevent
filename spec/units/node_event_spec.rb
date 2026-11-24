# frozen_string_literal: true

require_relative '../../lib/lowevent'

RSpec.describe Low::Events::NodeEvent do
  it 'is keyed by the node it renders' do
    node = Class.new

    expect([described_class.new(node:).key, described_class.new(node:).action]).to eq([node, :render])
  end
end
