# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/sidecar/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-sidecar"
  spec.version       = RSpec::Sidecar::VERSION
  spec.authors       = ["Luke Amdor"]
  spec.email         = ["luke.amdor@banno.com"]
  spec.summary       = "RSpec Helpers for testing sidecars"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rspec", "~> 3.1.0"
  spec.add_runtime_dependency "zk", "~> 1.9.4"
                              
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
