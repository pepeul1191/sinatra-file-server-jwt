# config/puma.rb
workers 2  # Cantidad de procesos de trabajo
threads 1, 6  # Mínimo y máximo de hilos por trabajador

preload_app!

port ENV.fetch("PORT") { 8090 }
environment ENV.fetch("RACK_ENV") { "development" }

on_worker_boot do
  # Configuración específica que necesitas ejecutar en cada trabajador al iniciar
end