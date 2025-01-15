@echo off
:: Variables
set FLUTTER_APP_DIR=client/web
set SERVER_DIR=server
set DART_RUN_CMD=dart run bin/server.dart
set FLUTTER_BUILD_CMD=flutter clean && flutter pub get && flutter build web --release --dart-define-from-file=../../.env
set FLUTTER_SERVE_CMD=flutter run -d chrome
set FLUTTER_SORT_IMPORTS_CMD=dart run import_sorter:main --no-comments

:: Funciones
:server
echo Iniciando servidor Dart...
cd %SERVER_DIR%
%DART_RUN_CMD%
cd ..
goto end

:web
echo Iniciando aplicación Flutter web...
cd %FLUTTER_APP_DIR%
%FLUTTER_SORT_IMPORTS_CMD%
%FLUTTER_SERVE_CMD%
cd ..
goto end

:build
echo Compilando aplicación Flutter web...
cd %FLUTTER_APP_DIR%
%FLUTTER_BUILD_CMD%
cd ..
echo Creando contenedores...
docker compose up --build -d
goto end

:clean
echo Limpiando proyectos...
cd %FLUTTER_APP_DIR%
flutter clean
flutter pub get
cd ..
cd %SERVER_DIR%
dart pub get
cd ..
goto end

:menu
echo.
echo ===============================
echo Seleccione una opción:
echo 1. Ejecutar servidor
echo 2. Ejecutar Flutter Web
echo 3. Compilar Flutter Web
echo 4. Limpiar proyectos
echo 0. Salir
echo ===============================
echo.
set /p choice=Ingrese su elección: 

if "%choice%"=="1" goto server
if "%choice%"=="2" goto web
if "%choice%"=="3" goto build
if "%choice%"=="4" goto clean
if "%choice%"=="0" goto exit
echo Opción no válida.
goto menu

:end
pause
goto menu

:exit
echo Saliendo...
exit
