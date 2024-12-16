# Usar la imagen oficial de PHP 7.4-FPM
FROM php:7.4-fpm

# Instalar dependencias y módulos necesarios para OwnCloud y MariaDB
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libzip-dev \
    libsqlite3-dev \
    libonig-dev \
    libldap2-dev \
    libbz2-dev \
    libxslt-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    zip intl gd xml curl pdo pdo_mysql mysqli bz2 opcache mbstring ldap xsl pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/
# Instalar Composer (opcional, para gestionar dependencias PHP)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configurar Opcache para mejor rendimiento
RUN echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.max_accelerated_files=4000" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.revalidate_freq=2" >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/opcache.ini

# Exponer el puerto 9000 para PHP-FPM
EXPOSE 9000
# Copiar el script de inicialización
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Establecer el entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
