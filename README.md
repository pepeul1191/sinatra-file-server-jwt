# Servidor de Recepción de Archivos

- [Documentación](#documentación)

Ejecución del servidor:

    $ gem install bundler
    $ bundler install
    $ rake server:development  # Inicia el servidor en modo de desarrollo
    $ rake server:production   # Inicia el servidor en modo de producción
    $ rake test:run

Archivo .env

    JWT_SECRET=k8sT!mZ$4KpQbR7sCv2EaXw&9LpQ
    HTTP_X_AUTH_TRIGGER=dXNlci1zdGlja3lfc2VjcmV0XzEyMzQ1Njc