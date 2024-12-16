# Usar Ubuntu como imagen base
FROM ubuntu:20.04

# Actualizar el sistema e instalar Nginx
RUN apt-get update && apt-get install -y nginx-full && apt install sed -y && apt-get clean && rm -rf /etc/nginx/nginx.conf && apt install -y openssl

#Argumentos y variables para el DOCKERFILE
ARG DOMAIN
ENV DOMAIN=${DOMAIN}

#Creación del certificado autofirmado para nginx
RUN sh -c "openssl req -x509 -nodes -days 365 \
-subj '/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN' \
-newkey rsa:2048 -keyout '/etc/ssl/certs/$DOMAIN.key' -out '/etc/ssl/certs/$DOMAIN.crt'"

#Copia la configuracion del nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Sustituye el domain1 por la variable del .env DOMAIN, ya que no lo hace de manera automática
RUN sed -i "s/domain1/$DOMAIN/g" /etc/nginx/nginx.conf

# Exponer el puerto 80 para que Nginx pueda aceptar conexiones
EXPOSE 80
EXPOSE 443

# Iniciar Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]