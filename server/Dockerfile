# Usa la última versión estable de Dart
FROM dart:stable AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia todo el contenido del contexto (incluyendo 'server' y 'shared')
COPY . /app/

# Establece el directorio de trabajo para la aplicación
WORKDIR /app/server

# Resuelve las dependencias de la app
RUN dart pub get

# Compila el binario AOT
RUN dart compile exe bin/server.dart -o bin/server

# Construye una imagen mínima con el binario AOT
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server/bin/server /app/bin/

# Expone el puerto y ejecuta el servidor
EXPOSE ${SERVER_PORT}

# Establece las variables de entorno
CMD ["/app/bin/server", "--dart-define=SERVER_PORT=${SERVER_PORT}", "--dart-define=BROKER_HOST=${BROKER_HOST}", "--dart-define=BROKER_PORT=${BROKER_PORT}"]
