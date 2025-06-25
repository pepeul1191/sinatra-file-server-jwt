require 'sinatra/base'
require 'json'
require 'jwt'
require 'logger'
require 'dotenv/load'
require 'rack/utils'

class ApplicationController < Sinatra::Base
  # Habilitar logging
  configure :development, :production do
    enable :logging
  end

  enable :sessions # Habilitar sesiones

  configure do
    set :session_secret, 'a4b89e6d2f4c7b98334f5e2c1e93460b2f94b24a6c9e5d073c44d4e69e839485'
    set :sessions, expire_after: 3600
    set :public_folder, File.join(Dir.pwd, 'uploads')
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
        { token: token }.to_json
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

  before '/api/v1/files/*' do
    authenticate!
  end

  get '/api/v1/files/:issue_id/:file_name' do
    issue_id = params[:issue_id]
    file_name = params[:file_name]
    # Carpeta donde están los archivos subidos
    upload_dir = File.join(Dir.pwd,'uploads', issue_id)
    file_path = File.join(upload_dir, file_name)
    unless File.exist?(file_path) && File.readable?(file_path)
      halt 404, { error: "File not found or not accessible" }.to_json
    end
    content_type MIME::Types.type_for(file_name).first.to_s || 'application/octet-stream'
    # Sirve el archivo como binario
    send_file file_path
  end

  post '/api/v1/files/:issue_id' do
    # Verificar si se envió un archivo
    unless params[:file] && params[:file][:tempfile]
      halt 400, { error: 'No se proporcionó ningún archivo' }.to_json
    end
    issue_id = params[:issue_id]
    uploaded_file = params[:file]
    begin
      # Obtener la extensión original del archivo
      original_filename = uploaded_file[:filename]
      extension = File.extname(original_filename)
      random_name = SecureRandom.uuid + extension
      # Crear directorio si no existe
      upload_dir = File.join('uploads', "#{issue_id}")
      FileUtils.mkdir_p(upload_dir) unless Dir.exist?(upload_dir)
      # Ruta completa del archivo
      file_path = File.join(upload_dir, random_name)
      # Guardar el archivo
      File.open(file_path, 'wb') do |f|
        f.write(uploaded_file[:tempfile].read)
      end
      # Devolver la ruta relativa (sin 'public')
      {
        status: 'success',
        filename: random_name,
        path: "/uploads/issue_#{issue_id}/#{random_name}",
        original_filename: original_filename,
        size: File.size(file_path)
      }.to_json
    rescue => e
      status 500
      { error: "Error al procesar el archivo: #{e.message}" }.to_json
    end
  end

  not_found do
    content_type :json
    status 404
    { 
      message: 'Recurso no encontrado', 
      error: "#{request.request_method} #{request.path} no existe"
    }.to_json
  end
end