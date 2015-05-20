# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shipwright/version'

Gem::Specification.new do |spec|
  spec.name          = "shipwright"
  spec.version       = Shipwright::VERSION
  spec.authors       = ["Adam Hunter"]
  spec.email         = ["adamhunter@me.com"]

  spec.summary       = %q[Deploy docker containers to AWS Elastic Beanstalk]
  spec.description   = %q[CLI Client for implementing the harbor pattern on AWS Elastic Beanstalk]
  spec.homepage      = "https://github.com/tma1/shipwright"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk', '~> 2'
  spec.add_dependency 'thor',    '~> 0.19.1'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.2.0"
end
