# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'active_permission/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_permission'
  spec.version       = ActivePermission::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Evgeniy Shurmin']
  spec.email         = ['eshurmin@gmail.com']
  spec.summary       = %q{Gem contain utility to allow/deny methods}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = 'http://github.com/jpascal/active_permission'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_path  = 'lib'

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'activesupport'
end
