FROM php:7.3-apache-buster

ENV DEBIAN_FRONTEND noninteractive

#
# Set project root to /app
#
WORKDIR /app
ENV HOME /app
ENV APACHE_DOCUMENT_ROOT /app/public

#
# Run "rootless"
#
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data

#
# Install all necessary libs and PHP modules
#
RUN	true \
#
# Update package list
#
    && apt-get update \
#
# Upgrade packages to fix potential security issues:
# - This will inflate our image, but the base image isn't updated quickly enough
#    
    && apt-get upgrade -y \
#
# Install all necessary PHP mods
#
    && apt-get install -y --no-install-recommends \
        libxml2-dev zlib1g-dev libpq-dev libsodium-dev libgmp-dev libzip-dev \
        libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxpm-dev libwebp-dev \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        --with-xpm-dir=/usr/incude/ --with-webp-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd xml pgsql pdo_pgsql zip gmp intl opcache \
#
# Use the default PHP production configuration
#
    && mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
#
# Install all other tools
#
    && apt-get install -y --no-install-recommends localehelper msmtp msmtp-mta vim \
#
# Install composer 1.9
#
    && curl https://getcomposer.org/download/1.9.3/composer.phar --output /usr/bin/composer  \
    && chmod a+x /usr/bin/composer \
#
# Prepare folder structure ...
#
    && mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views storage/app \
    && chown -R ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /app \
#
# Setup apache
#
    && a2enmod rewrite actions deflate expires headers \
    && echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && a2enconf fqdn \
#
# Setup apache
#
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && sed -ri -e 's!80!8080!g' /etc/apache2/sites-available/*.conf /etc/apache2/ports.conf \
#
# Optionally include an Apache2 config file from within the Laravel HOME (/app) directory
#
    && echo "IncludeOptional $HOME/.apache2.conf" > /etc/apache2/sites-enabled/999-optional.conf \
#
# Create empty startup script
#
    && echo "#!/bin/sh" > /container-startup.sh \
    && chmod u+x /container-startup.sh \
    && chown ${APACHE_RUN_USER}:${APACHE_RUN_GROUP} /container-startup.sh \
#
# Clean-up
#
    && rm -rf /var/lib/apt/lists/* /usr/share/vim

#
COPY ./laravel-php.ini $PHP_INI_DIR/conf.d/zzzz-laravel.ini

# Disable warning for running composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Configure OPCACHE
ENV OPCACHE_ENABLE=1
ENV OPCACHE_VALIDATE_TIMESTAMPS=1
ENV OPCACHE_REVALIDATE_FREQ=2
ENV OPCACHE_FILE_CACHE=""

#
USER ${APACHE_RUN_USER}

#
EXPOSE 8080/tcp

#
CMD ["bash", "-c", "/container-startup.sh && exec apache2-foreground"]
