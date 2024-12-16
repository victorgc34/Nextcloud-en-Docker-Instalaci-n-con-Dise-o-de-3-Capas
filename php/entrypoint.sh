#!/bin/bash

DB_HOST="192.168.3.5"
DB_PORT=3306
WAIT_TIMEOUT=30

# Iniciar PHP-FPM en segundo plano
php-fpm &

# Función para esperar a que MariaDB esté disponible
wait_for_db() {
  echo "Esperando a que la base de datos en $DB_HOST:$DB_PORT esté disponible..."
  for ((i=1; i<=WAIT_TIMEOUT; i++)); do
    if php -r "try { new PDO('mysql:host=$DB_HOST;port=$DB_PORT;', '$DB_USER', '$DB_PASS'); exit(0); } catch (Exception \$e) { exit(1); }"; then
      echo "La base de datos está disponible."
      return 0
    fi
    echo "Intento $i/$WAIT_TIMEOUT: La base de datos no está lista, esperando..."
    sleep 2
  done
  echo "Error: La base de datos no está disponible después de $WAIT_TIMEOUT segundos."
  exit 1
}

# Ejecutar instalación de OwnCloud
install_owncloud() {
  echo "Iniciando instalación de OwnCloud..."
  su -s /bin/bash www-data -c "php /var/www/owncloud/occ maintenance:install \
    --database 'mysql' \
    --database-name '$DB_NAME' \
    --database-user '$DB_USER' \
    --database-pass '$DB_PASS' \
    --database-host '$DB_HOST' \
    --admin-user '$ADMIN_USER' \
    --admin-pass '$ADMIN_PASS'"
  echo "Instalación de OwnCloud completada."
}

# Agregar dominios confiables (los trusted domains)
add_trusted_domains() {
  echo "Agregando dominios confiables..."
  su -s /bin/bash www-data -c "php /var/www/owncloud/occ config:system:set trusted_domains 0 --value='$DOMAIN'"
  su -s /bin/bash www-data -c "php /var/www/owncloud/occ config:system:set trusted_domains 1 --value='192.168.3.2'"
  su -s /bin/bash www-data -c "php /var/www/owncloud/occ config:system:set trusted_domains 2 --value='192.168.3.3'"
  su -s /bin/bash www-data -c "php /var/www/owncloud/occ config:system:set trusted_domains 3 --value='192.168.3.4'"
  echo "Dominios confiables agregados correctamente."
}

# Lógica principal
wait_for_db
install_owncloud
add_trusted_domains

# Esperar a que PHP-FPM termine
wait
