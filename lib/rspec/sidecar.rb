require "rspec/sidecar/version"
require "rspec"

module RSpec
  module Sidecar
  end
end

require 'rspec/sidecar/wait_until'
require 'rspec/sidecar/services'

RSpec.configure do |c|
  c.include RSpec::Sidecar::WaitUntil
  c.include RSpec::Sidecar::Services
end
