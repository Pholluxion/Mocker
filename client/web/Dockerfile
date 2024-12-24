FROM nginx:alpine

# Copia los archivos generados de la compilación de Flutter al directorio adecuado de Nginx
COPY /build/web /usr/share/nginx/html

# Expone el puerto 80 para servir la aplicación
EXPOSE 80

# Comando por defecto de Nginx
CMD ["nginx", "-g", "daemon off;"]
