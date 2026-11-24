# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Minor features that don't break backwards compatibility are released as patches.


## 0.8.8

### Added

- `internal?` says whether an event's tree is kept apart from the app's like an interval's tick. The pool keeps it apart without a rule

### Removed

- `HiddenEvent#trigger` and `HiddenEvent.trigger` which called methods it didn't have and nothing used

## 0.8.7

### Added

- `keep_apart { |event| ... }` keeps the trees whose first event the block picks in a buffer of their own of 20. A framework's own pages or an interval's ticks then never push the app's requests out and `event_trees` leaves them out

## 0.8.6

### Added

- `record { ... }` times work that isn't an observer like rendering a node or running a query. It joins the tree of the request or interval happening now with the events it causes under it and outside one it only runs the work
- `NodeEvent` times a node rendering inside another. It holds the timing so `RenderEvent` stays immutable
- `starts_event_tree?` says whether an event starts a tree of its own like a request

### Fixed

- An event triggered or taken by an observer goes under the event it observes and the event before it is current again once it's finished. Events after the first used to all go under the first so a tree didn't show what caused what

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
