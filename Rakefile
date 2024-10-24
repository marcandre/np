# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

PARCEL_OPTIONS = 'assets/index.* --public-url /assets --dist-dir dist'

desc 'Start local server'
task :serve do
  fork do
    exec "cd app && npx parcel watch --no-hmr #{PARCEL_OPTIONS}"
  end
  system "rerun -d app,lib --pattern '**/*.{rb,ru,slim,yaml}' bundle exec rackup"
end

desc '* Build assets, prepare for release *'
task :build_assets do
  raise 'Must be clean' if `git status --porcelain` != ''

  [
    'git branch -D release &>/dev/null',
    'git switch -c release',
    "cd app && npx parcel build #{PARCEL_OPTIONS}",
    'git add app/dist -f',
    'git commit -m "Bundle assets for release"',
    'git checkout .',
    'git switch -',
  ].each do |cmd|
    puts cmd
    system cmd
  end
  puts 'Release ready with `git push heroku release:master -f`'
end
