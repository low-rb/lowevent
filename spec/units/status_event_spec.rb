# frozen_string_literal: true

require 'observers'

require_relative '../../lib/lowevent'

RSpec.describe Low::Events::StatusEvent do
  let(:any_status) { Class.new { include Observers } }
  let(:not_found) { Class.new { include Observers } }
  let(:other) { Class.new { include Observers } }

  before do
    Observers::Keys.reset
    any_status.observe Low::Types::Status
    not_found.observe Low::Types::Status[404]
    other.observe '/about'
  end

  it 'lists what observes any status or a status code' do
    expect(described_class.observers.to_a.map(&:object)).to eq([any_status, not_found])
  end
end
