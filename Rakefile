# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :serve do
  fork do
    exec 'cd app && parcel watch assets/index.* --global App --no-hmr --public-url /assets'
  end
  system "rerun -d app,lib --pattern '**/*.{rb,ru,slim,yaml}' bundle exec rackup"
end
