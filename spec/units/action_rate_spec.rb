# frozen_string_literal: true

require_relative '../../lib/lowevent'

RSpec.describe Low::Events::ActionRate do
  subject(:rate) { described_class.new }

  it 'averages the events of the last minute over each second' do
    30.times { rate.count(now: 100.2) }
    90.times { rate.count(now: 130.7) }

    expect(rate.per_second(now: 131)).to eq(2.0)
  end

  it 'forgets seconds over a minute ago' do
    60.times { rate.count(now: 100) }
    6.times { rate.count(now: 161) }

    expect(rate.per_second(now: 161)).to eq(0.1)
  end

  it 'counts each event the pool runs, kept apart or not' do
    pool = Low::Events::EventPool.new
    allow(Providers).to receive(:[]).with('low.event.pool').and_return(pool)
    pool.keep_apart { |event| event.key == :internal }
    LowEvent.new(key: :app).trigger
    LowEvent.new(key: :internal).trigger

    expect(pool.action_rate.per_second).to eq((2 / 60.0).round(1))
  end
end
