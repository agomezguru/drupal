# ====================================================================================
#   Thanks to Daniel Ribeiro for his work (https://github.com/drgomesp/symfony-docker)
#   And of course to Chema (https://github.com/jmsv23/docker-drupal)
# ====================================================================================

# This container is intended to be used like base common place for the Drupal projects 
# currently only tested with 9 version.

# This Dockerfile was created 19/04/2021 for reuse the Docker build images more efficiently
# so, please don't be use directly. For more details see the comments at the end of this file. 
# Last updated: 2/01/2024 16:43 

# Use an official PHP runtime as a parent image.
# Ref.: https://www.drupal.org/docs/system-requirements/php-requirements
FROM php:8.3.1-fpm 

LABEL maintainer="Alejandro Gomez Lagunas <alagunas@coati.com.mx>"

# Install any needed packages and clear cache
RUN set=-eux pipefail; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
      git \
      libicu-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmagickwand-dev \
      libmcrypt-dev \
      libpng16-16 \
      libpng-dev \
      libwebp7 \
      libxml2-dev \
      libxslt1-dev \
      libzip-dev \
      mariadb-client \
      webp; \
    rm -rf /var/lib/apt/lists/*

# Install the PHP gd library
RUN docker-php-ext-configure gd \
  --with-freetype \
  --with-jpeg \
  --with-webp; \
docker-php-ext-install -j$(nproc) gd

# Run docker-php-ext-install for available extensions
RUN set=-eux pipefail; \
  docker-php-ext-install intl; \
  docker-php-ext-install soap; \
  docker-php-ext-install xsl; \
  docker-php-ext-install zip; \
  docker-php-ext-install opcache; \
  docker-php-ext-install sockets

RUN pecl install imagick-3.7.0 && docker-php-ext-enable imagick
RUN pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-enable redis

# Install Composer
RUN curl -sS https://getcomposer.org/installer | \
  php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Set your timezone here...
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/America/Mexico_City /etc/localtime
RUN "date"

# Database driver connection to percona.
RUN docker-php-ext-install pdo_mysql

# Add drush to cli
ENV PATH=/srv/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /srv
# tag: agomezguru/drupal:10.x-php8.3.x
# Example: docker build . --tag agomezguru/drupal:10.x-php8.3.x

# If you desire use this Docker Image directly, uncomment the next line. 
# CMD php-fpm -F

# End of file
