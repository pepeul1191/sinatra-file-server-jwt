module Helpers
  def authenticate!
    begin
      auth_header = request.env['HTTP_AUTHORIZATION']
      halt 401, { error: 'Missing Authorization header' }.to_json unless auth_header

      token = auth_header.gsub(/^Bearer\s/, '') # Remueve "Bearer " si está presente

      decoded_token = JWT.decode(token, settings.jwt_secret, true, algorithm: 'HS256')

      # Guardar información del token para usarla en la ruta (opcional)
      @current_user = decoded_token[0]['sub'] # por ejemplo
    rescue JWT::DecodeError => e
      halt 401, { error: 'Invalid token', message: e.message }.to_json
    rescue => e
      halt 500, { error: 'Internal server error', message: e.message }.to_json
    end
  end
end