require "rspec/sidecar/version"
require "rspec"

module RSpec
  module Sidecar
  end
end

require 'rspec/sidecar/wait_until'
require 'rspec/sidecar/services'
require 'rspec/sidecar/app_availability'

RSpec.configure do |c|
  c.include RSpec::Sidecar::WaitUntil
  c.include RSpec::Sidecar::Services
  c.include RSpec::Sidecar::AppAvailability
end
