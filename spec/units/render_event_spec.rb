# frozen_string_literal: true

require_relative '../../lib/lowevent'

RSpec.describe Low::Events::RenderEvent do
  it 'defaults to rendering without props or params' do
    event = described_class.new

    expect([event.action, event.props, event.params]).to eq([:render, {}, {}])
  end

  it 'has params' do
    expect(described_class.new(params: { id: '1' }).params).to eq({ id: '1' })
  end
end
