lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'phabricator/version'

Gem::Specification.new do |spec|
  spec.name          = 'phabricator'
  spec.version       = Phabricator::VERSION
  spec.authors       = ['Amber Feng']
  spec.email         = ['amber.feng@gmail.com']
  spec.description   = %q{Wrapper around Phabricator's Conduit API}
  spec.summary       = %q{Wrapper around Phabricator's Conduit API}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'rest-client'

  spec.add_development_dependency 'minitest', '< 5.0'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  
  spec.add_development_dependency 'bundler', '~> 2.2.33'
end
