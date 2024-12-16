#$IP_MAS=rango de IPs de los servidores Web (no poner máscara de red ya que mysql no lo permite)
#$db_passwd=contraseña_usuario_root_database
#$DB_USER=es el usuario utilizado para la base de datos Wordpress
#$DB_PASS=contraseña del usuario para la base de datos Wordpress

DB_USER=user_owncloud
DB_PASS=GHHJHSGDY

IP_MAS=192.168.7.%
#Esta debe de coincidir con la variable indicada en el docker-compose
db_passwd=1234contrasena

#######################
#######################

#Crea la base de datos para Wordpress (El nombre de la base de datos es wordpress_db)
mariadb -u root -p$db_passwd -e "CREATE DATABASE owncloud_db;FLUSH PRIVILEGES;"

# Creación de un nuevo usuario de MySQL y asignación de privilegios
mariadb -u root -p$db_passwd -e "CREATE USER '$DB_USER'@'$IP_MAS' IDENTIFIED BY '$DB_PASS';"
mariadb -u root -p$db_passwd -e "GRANT ALL PRIVILEGES ON owncloud_db.* TO '$DB_USER'@'$IP_MAS';FLUSH PRIVILEGES;"
