require_relative 'server'
run Sinatra::Application
map '/assets' do
  run Rack::Directory.new('dist')
end
