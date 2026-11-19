# frozen_string_literal: true

require_relative '../../lib/lowevent'

RSpec.describe Low::Events::RequestEvent do
  # Answers the request, like a router.
  let(:router) { Class.new { def request(event:) = "page for #{event.request}" }.new }
  # Turns some requests away before the router, and adds to every response on its way out.
  let(:guard) do
    Class.new do
      def request(event:) = (+'turned away' if event.request == '/forged')
      def response(result:, **) = result << ' with a cookie'
    end.new
  end

  before do
    Observers::Keys.reset
    allow(Fiber).to receive(:current).and_return(Object.new)
    described_class.define { |observers| observers << router }
  end

  it 'puts an observer first when define returns a new order' do
    described_class.define do |observers|
      observers = [guard, *observers] # rubocop:disable Lint/UselessAssignment
    end

    expect(Observers[described_class].map(&:object)).to eq([guard, router])
  end

  it "keeps the order when define's block only adds observers" do
    described_class.define { |observers| observers << guard }

    expect(Observers[described_class].map(&:object)).to eq([router, guard])
  end

  it 'lets the first observer turn a request away, and passes the response back along every observer' do
    described_class.define { |observers| [guard, *observers] }

    expect([described_class.take(request: '/forged'), described_class.take(request: '/cart')])
      .to eq(['turned away with a cookie', 'page for /cart with a cookie'])
  end

  it 'is current while it is answered, so what answers it can keep things in its store' do
    keeper = Class.new { def request(event:) = Low::Events::RequestEvent.current.store[:seen] = event.request }.new
    described_class.define { |observers| [keeper, *observers] }
    event = described_class.new(request: '/cart')
    event.take

    expect([event.store, described_class.current]).to eq([{ seen: '/cart' }, event])
  end
end
