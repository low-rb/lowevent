# frozen_string_literal: true

require 'providers'

require_relative 'events/render_event'
require_relative 'events/request_event'
require_relative 'events/response_event'
require_relative 'events/status_event'
require_relative 'factories/response_factory' # TODO: Find out who's using this and require it there.
require_relative 'interfaces/event'
require_relative 'pool/event_pool'

Providers.define('low.event.pool') do
  Low::Events::EventPool.new
end

LowEvent = Low::Event
