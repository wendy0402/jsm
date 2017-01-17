# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jsm/version'

Gem::Specification.new do |spec|
  spec.name          = "just_state_machine"
  spec.version       = Jsm::VERSION
  spec.authors       = ["wendy0402"]
  spec.email         = ["wendykurniawan92@gmail.com"]

  spec.summary       = "Just State Machine, State Machine That support custom validations, it also known with Jsm"
  spec.description   = "Just StateMachine"
  spec.homepage      = "https://github.com/wendy0402/jsm"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activerecord", ">= 4.0"
end
