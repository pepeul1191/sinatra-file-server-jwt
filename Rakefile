namespace :server do
  desc "Ejecuta la aplicación en modo desarrollo"
  task :development do
    ENV['RACK_ENV'] = 'development'
    # Comando para reiniciar automáticamente el servidor con rerun
    command = "bundle exec puma -C config/puma.rb"
    dirs_to_watch = "app,config"
    rerun_command = "rerun --dir #{dirs_to_watch} '#{command}'"
    sh rerun_command
  end

  desc "Ejecuta la aplicación en modo prueba"
  task :test do
    ENV['RACK_ENV'] = 'test'
    # Aquí podrías agregar configuraciones adicionales específicas para pruebas
    sh "bundle exec puma -C config/puma.rb"
  end

  desc "Ejecuta la aplicación en modo producción"
  task :production do
    ENV['RACK_ENV'] = 'production'
    ENV['PORT'] = '80'  # Ejemplo: Cambiando el puerto en producción
    sh "bundle exec puma -C config/puma.rb"
  end
end