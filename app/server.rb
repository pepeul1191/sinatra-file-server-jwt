require 'sinatra/base'

class ApplicationController < Sinatra::Base
  # Habilitar logging
  configure :development, :production do
    enable :logging
  end

  enable :sessions # Habilitar sesiones

  configure do
    set :session_secret, 'a4b89e6d2f4c7b98334f5e2c1e93460b2f94b24a6c9e5d073c44d4e69e839485'
    set :sessions, expire_after: 3600
    set :public_folder, File.join(Dir.pwd, 'public')
    set :constants, CONSTANTS[:local]
  end

  before do
    env["rack.logger"] = Logger.new(STDOUT)
  end

  helpers Helpers

  get '/' do
    hola()
    'hol'
  end
end