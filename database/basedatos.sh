#$IP_MAS=rango de IPs de los servidores Web (no poner máscara de red ya que mysql no lo permite)

IP_MAS=192.168.3.%

#######################
#######################

#Crea la base de datos para Wordpress
mariadb -u root -p$DB_PASSWD -e "CREATE DATABASE $DB_NAME;FLUSH PRIVILEGES;"

# Creación de un nuevo usuario de MySQL y asignación de privilegios
mariadb -u root -p$DB_PASSWD -e "CREATE USER '$DB_USER'@'$IP_MAS' IDENTIFIED BY '$DB_PASS';"
mariadb -u root -p$DB_PASSWD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$IP_MAS';FLUSH PRIVILEGES;"
