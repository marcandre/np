# frozen_string_literal: true

require_relative 'lib/np/version'

Gem::Specification.new do |spec|
  spec.name          = 'np'
  spec.version       = Np::VERSION
  spec.authors       = ['Marc-Andre Lafortune']
  spec.email         = ['github@marc-andre.ca']

  spec.summary       = 'np.'
  spec.description   = 'np.'
  spec.homepage      = 'http://github.com/marcandre/np'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'http://github.com/marcandre/np'
  spec.metadata['changelog_uri'] = 'http://github.com/marcandre/np/Changelog.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rubocop-ast', '>= 0.7.0'
  spec.add_runtime_dependency 'require_relative_dir'
  spec.add_runtime_dependency 'sinatra', "~> 4.0"
  spec.add_runtime_dependency 'sinatra-contrib'
  spec.add_runtime_dependency 'slim'
  spec.add_runtime_dependency 'faye-websocket'
end
