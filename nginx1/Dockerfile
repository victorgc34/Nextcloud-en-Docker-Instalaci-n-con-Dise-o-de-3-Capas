# Usa Ubuntu como imagen base
FROM ubuntu:20.04

# Variables de entorno
ENV DEBIAN_FRONTEND=noninteractive

# Actualiza el sistema e instala dependencias
RUN apt-get update && apt-get install -y \
    sed \
    supervisor \
    nginx-full \
    curl \
    unzip \
    mariadb-client \
    netcat && \   
    apt-get clean \
    open-ssl

# Descarga y extrae OwnCloud
RUN curl -L -o /var/www/owncloud.zip https://download.owncloud.com/server/stable/owncloud-complete-20240724.zip && \
    unzip -o /var/www/owncloud.zip -d /var/www/ && \
    rm /var/www/owncloud.zip && \
    chown -R www-data:www-data /var/www/owncloud && \
    chown -R www-data:www-data /var/www/owncloud

# Copia el archivo de configuración de Nginx
COPY nginx-owncloud.conf /etc/nginx/sites-available/default

# Configuración de supervisor para ejecutar el servicio nginx
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expone el puerto 80
EXPOSE 80

# Comando de inicio
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
