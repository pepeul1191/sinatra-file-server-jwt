require 'sinatra/base'
require 'json'
require 'jwt'
require 'logger'
require 'dotenv/load'

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
    set :auth_header, ENV['AUTH_HEADER']
    set :jwt_secret, ENV['JWT_SECRET']
  end

  before do
    env["rack.logger"] = Logger.new(STDOUT)
  end

  helpers Helpers

  get '/' do
    hola()
    'hol'
  end

  post '/api/v1/sign-in' do
    incoming_auth = request.env['HTTP_X_AUTH_TRIGGER']
    # puts "Incoming X-Auth-Trigger: #{incoming_auth}"
    # puts "Expected AUTH_HEADER: #{settings.auth_header}"
    if incoming_auth == settings.auth_header
      puts "Authentication successful. Generating JWT."
      claims = {
        iss: 'your-app.com',
        aud: 'your-client-id',
        sub: 'user@example.com',
        exp: Time.now.to_i + 3600, # 1 hora
        iat: Time.now.to_i,
        user_id: 123,
        role: 'admin'
      }
      begin
        token = JWT.encode claims, settings.jwt_secret, 'HS256'
        { status: 'success', token: token }.to_json
      rescue => e
        puts "Failed to encode JWT: #{e.message}"
        halt 500, { error: 'Failed to generate token' }.to_json
      end
    else
      puts "Unauthorized access attempt. Invalid or missing X-Auth-Trigger."
      status 401
      { error: 'Unauthorized', message: 'Invalid or missing X-Auth-Trigger' }.to_json
    end
  end
end