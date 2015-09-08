# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinclair/version'

Gem::Specification.new do |spec|
  spec.name          = 'sinclair'
  spec.version       = Sinclair::VERSION
  spec.authors       = ['Pivotal IAD']
  spec.email         = ['iad-dev@pivotal.io']

  spec.summary       = %q{Sinclair is a gem that makes using the OpenAir API tolerable.}
  spec.description   = %q{Sinclair is a gem that makes using the OpenAir API tolerable.}
  spec.homepage      = 'http://github.com/pivotal/sinclair'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'nori', '~> 2.6.0'
  spec.add_dependency 'faraday', '~> 0.9.0'
  spec.add_dependency 'nokogiri', '~> 1.6.0'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
end
