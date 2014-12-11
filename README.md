# RSpec::Sidecar

Includes helpers for RSpec to test sidecars

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-sidecar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-sidecar

## Usage

Includes the helpers:

  - `wait_until(timeout=30, &blk)`: calls the block continually until either it returns a truthy value or timeout occurs and it blows up
