require "rspec/sidecar/version"
require "rspec"

module RSpec
  module Sidecar
  end
end

require 'rspec/sidecar/wait_until'

RSpec.configure do |c|
  c.include RSpec::Sidecar::WaitUntil
end
