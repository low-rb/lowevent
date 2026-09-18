<a href="https://rubygems.org/gems/lowevent" title="Install gem"><img src="https://badge.fury.io/rb/lowevent.svg" alt="Gem version" height="18"></a>

# LowEvent

LowEvent is a framework for event-driven applications where events are present-tense, not past-tense.

## Events

LowEvent represents events of all kinds; `RequestEvent`, `RouteEvent`, `RenderEvent` and `ResponseEvent`.

Inherit from `LowEvent` to create your own event:

```ruby
class MyEvent < LowEvent
  def initialize(data:, action: :render)
    super(key: self.class, action:)
    @data = data
  end
end
```

## Observers

Observe the event with:

```ruby
class MyObserver
  include Observers
  observe MyEvent

  def render(event:)
    event.data
  end
end
```

Trigger the event's action on its observers with:
```ruby
MyEvent.trigger(data: "Custom Data")
```

ℹ️ For more info see [Observers](https://github.com/raindeer-rb/observers).

## Architecture

A LowEvent is primarily concerned with what is *happening*, not what has *happened*.

### Comparison

An Event-Command Hybrid:

|                  | **Event**       | **LowEvent**           | **Command**    |
|------------------|-----------------|------------------------|----------------|
| **Tense**        |   Past          | Past/Present/Future  |   Future       |
| **Naming**       |   OrderCreated  | OrderEvent           |   CreateOrder  |
| **Action**       |   🚫            | :create_order        |   ✅            |
| **Mutability**   |   Immutable     | Mutable/Immutable    |   Immutable    |
| **State**        |                 | Ordered Actions      |   🚫            |
| **Broadcasting** |   One to many   | Ordered one to many  |   One to one   |
| **Return value** |   🚫            | Value or nil         |   Value         |

### Event Tree

LowEvent builds a tree of every event as it's occuring and every subsequent event that occurs because of that event:

<p align="center"><img src="assets/Event Tree.svg" alt="Event Tree" height="400"/></p>

## Installation

Add `gem 'lowevent'` to your Gemfile then:
```
bundle install
```
