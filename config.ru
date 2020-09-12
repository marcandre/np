require_relative 'app/server'
run Sinatra::Application
map '/assets' do
  run Rack::Directory.new('app/dist')
end
