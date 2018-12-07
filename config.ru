require 'bundler'
Bundler.require

puts 'Starting...'

Faye::WebSocket.load_adapter('thin')
use Faye::RackAdapter, mount: '/faye', timeout: 25

use Rack::Static,
    root: 'public',
    urls: ['/stylesheets',
           '/images',
           '/javascripts']

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets'
  run environment
end

map '/' do
  run Rack::File.new('views/player.html')
end

map '/master' do
  use Rack::Auth::Basic, 'Geek Master' do |username, password|
    username == 'geek' && password ==  File.read('.geekpw')
  end
  run Rack::File.new('views/master.html')
end

puts 'Ready.'
