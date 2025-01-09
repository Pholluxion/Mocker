# Variables

# Directorio de tu app Flutter
FLUTTER_APP_DIR = client/web

# Directorio de tu servidor Dart
SERVER_DIR = server

# Comando para ejecutar el servidor Dart
DART_RUN_CMD = dart run bin/server.dart

# Comando para compilar Flutter para web
FLUTTER_BUILD_CMD = flutter clean;flutter pub get; flutter build web --release --dart-define-from-file=../../.env

# Comando para ejecutar Flutter en modo web
FLUTTER_SERVE_CMD = flutter run -d chrome 

#Ordenar importaciones
FLUTTER_SORT_IMPORTS_CMD = dart run import_sorter:main --no-comments

# Reglas

.PHONY: all server web build_web

# Ejecutar solo el servidor Dart
server:
	@echo "Iniciando servidor Dart..."
	cd $(SERVER_DIR) && $(DART_RUN_CMD)

# Ejecutar Flutter Web
web:
	@echo "Iniciando aplicación Flutter web..."
	
	cd $(FLUTTER_APP_DIR) && $(FLUTTER_SORT_IMPORTS_CMD) && $(FLUTTER_SERVE_CMD)

# Compilar Flutter Web
build:
	@echo "Compilando aplicación Flutter web..."
	cd $(FLUTTER_APP_DIR) && $(FLUTTER_BUILD_CMD)
	@echo "Creando contenedores"
	docker compose up --build -d

# Limpiar ambos proyectos
clean:
	@echo "Limpiando proyectos..."
	cd $(FLUTTER_APP_DIR) && flutter clean && flutter pub get
	cd $(SERVER_DIR) && dart pub get

