# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'excess_flow/constants'

Gem::Specification.new do |spec|
  spec.name          = 'excess_flow'
  spec.version       = ExcessFlow::VERSION
  spec.authors       = ['ConvertKit, LLC']
  spec.email         = ['engineering@convertkit.com']

  spec.summary       = 'Redis based rate limiter'
  spec.description   = 'Hihg precision simple redis based rate limiter.'
  spec.license       = 'Apache License Version 2.0'

  spec.metadata['source_code_uri'] = 'https://github.com/ConvertKit/excess_flow'

  spec.files = `git ls-files | grep -Ev '^(spec)'`.split("\n")

  spec.executables = ['console']
  spec.require_paths = ['lib']

  spec.add_dependency 'connection_pool'
  spec.add_dependency 'rake'
  spec.add_dependency 'redis'
end
