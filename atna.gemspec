# coding: utf-8 -*- mode: ruby -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atna/version'

Gem::Specification.new do |spec|
  spec.name          = "atna"
  spec.version       = Atna::VERSION
  spec.authors       = ["Tetsuhisa MAKINO"]
  spec.email         = ["tim.makino@gmail.com"]
  spec.summary       = %q{IHE ITI ATNA Udp socket logger with RFC3881 Message builder.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # for Development
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  # for production
  spec.add_dependency "nokogiri"
end
