# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinclair/version'

Gem::Specification.new do |spec|
  spec.name          = 'sinclair'
  spec.version       = Sinclair::VERSION
  spec.authors       = ['Pivotal IAD']
  spec.email         = ['iad-dev@pivotal.io']

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'http://github.com/pivotal/sinclair'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'nori', '~> 2.6.0'
  spec.add_dependency 'faraday', '~> 0.9.0'
  spec.add_dependency 'nokogiri', '~> 1.4.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
end
