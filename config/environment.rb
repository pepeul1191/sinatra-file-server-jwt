require 'bundler'
require 'bundler/setup'
Bundler.require

configure :development do
  set :show_exceptions, true
end

configure :production do
  set :show_exceptions, false
end

require_all 'config/initializers'
require_all 'app'
# require_all 'app/apis'
