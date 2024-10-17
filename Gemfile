# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in np.gemspec
gemspec

gem 'rackup', '~> 2.0'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'

gem 'rubocop'
gem 'puma'
local_ast = File.expand_path('../rubocop-ast', __dir__)
if Dir.exist?(local_ast) && ENV['LOCAL']
  gem 'rubocop-ast', path: local_ast
#else
#  gem 'rubocop-ast', git: 'https://github.com/marcandre/rubocop-ast.git', branch: 'node_pattern_release'
end
gem 'rerun'
