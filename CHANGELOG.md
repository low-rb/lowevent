# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Minor features that don't break backwards compatibility are released as patches.


## 0.8.5

### Changed

- `created_at` counts fractions of a millisecond as most events take less than one

### Added

- An event records `finished_at` when its trigger or take returns and `milliseconds` says how long that took including the events it caused
- `StatusEvent.observers` lists what observes `Status` or a `Status[code]` as nodes observe those rather than the event

## 0.8.4

### Added

- `define` puts observers in the order its block returns, so `observers = [MyLogger, *observers]` puts one first
- A return action for events, like `RequestEvent`'s `response`, which each observer its take passed gets on the way back out, as `response(event:, result:)`, with the response it took, and can add to it, like a cookie

### Changed

- Need Observers 1.1.1, which reorders observers and passes a take's result back

## 0.8.3

### Added

- Give `RenderEvent` a route's `request`

## 0.8.2

### Fixed

- Give `RenderEvent` a route's `params`

## 0.8.0

### Added

- Support multiple ordered actions

### Changed

- Rename default action to request

## 0.7.0

### Added

- Provide event count stat

### Changed

- Trigger specific `Status[code]` first then general `Status`

## 0.6.0

### Added

- Introduce `Event.define do |observers|` API

## 0.5.0

### Added

- Introduce hidden events
- Trigger "new event tree" event via event pool

### Changed

- Split event trees up by request event
- Replace low dependency with providers

## 0.4.0

### Added

- Introduce event pool and event tree
- Timestamp when events are created

### Changed

- StatusEvent: Default to render action

### Fixed

- Fix bug where `@key` instance variable wasn't populated yet

## 0.3.0

### Added

- Integrate with Observers
- Consider LowEvent a value object

## 0.2.0

### Added

- Add status event

## 0.1.0

### Added

- Support render, request and response events
