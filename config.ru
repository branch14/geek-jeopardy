require 'bundler'
Bundler.require

use Rack::Static,
  :root => "public",
  :urls => [ "/stylesheets",
             "/images",
             "/javascripts" ]

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path 'assets'
  run environment
end

map '/' do
  run Rack::File.new("views/player.html")
end

map '/master' do
  use Rack::Auth::Basic, "Geek Master" do |username, password|
    username == 'geek' && password ==  File.read('geekpw')
  end
  run Rack::File.new("views/master.html")
end

