# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog_proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "datadog_proxy"
  spec.version       = DatadogProxy::VERSION
  spec.authors       = ["Ryota Arai"]
  spec.email         = ["ryota-arai@cookpad.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'sinatra', '~> 1.4.5'
  spec.add_dependency 'dogapi', '~> 1.10.0'
  spec.add_dependency 'dotenv', '~> 0.11.1'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", "~> 3.0.0"
end
