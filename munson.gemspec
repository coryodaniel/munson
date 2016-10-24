# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'munson/version'

Gem::Specification.new do |spec|
  spec.name          = "munson"
  spec.version       = Munson::VERSION
  spec.authors       = ["Cory O'Daniel"]
  spec.email         = ["cory@coryodaniel.com"]

  spec.summary       = %q{A JSON API Spec client for Ruby}
  spec.homepage      = "http://github.com/coryodaniel/munson"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "pry", "= 0.9.10"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "json", "= 1.8"
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'webmock'
end
