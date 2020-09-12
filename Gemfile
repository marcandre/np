# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in np.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'

gem 'rubocop'
local_ast = File.expand_path('../rubocop-ast', __dir__)
if Dir.exist? local_ast
  gem 'rubocop-ast', path: local_ast
end
gem 'rerun'
