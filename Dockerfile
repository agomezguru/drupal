# ====================================================================================
#   Thanks to Daniel Ribeiro for his work (https://github.com/drgomesp/symfony-docker)
#   And of course to Chema (https://github.com/jmsv23/docker-drupal)
# ====================================================================================

# This container is intended to be used like base common place for the Drupal projects 
# currently only tested with 9 version.

# This Dockerfile was created 19/04/2021 for reuse the Docker build images more efficiently
# so, please don't be use directly. For more details see the comments at the end of this file. 
# Last updated: 29/08/2022 12:33 

# Use an official PHP runtime as a parent image.
# Ref.: https://www.drupal.org/docs/system-requirements/php-requirements
FROM php:8.1.15-fpm

LABEL maintainer "Alejandro Gomez Lagunas <alagunas@coati.com.mx>"

# Get the last available packages
RUN apt update

# Install any needed packages
RUN apt install -y libpng16-16
RUN apt install -y libpng-dev
RUN apt install -y git
RUN apt install -y mariadb-client
RUN apt install -y libicu-dev
RUN apt install -y libfreetype6-dev
RUN apt install -y libjpeg62-turbo-dev
RUN apt install -y libxml2-dev
RUN apt install -y libxslt1-dev
RUN apt install -y libmcrypt-dev
RUN apt install -y libzip-dev
RUN apt install -y libwebp-dev
RUN apt install -y libwebp6
RUN apt install -y webp
RUN apt install -y libmagickwand-dev --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Run docker-php-ext-install for available extensions
RUN docker-php-ext-configure gd --with-freetype \
  --with-jpeg --with-webp && docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install intl
RUN docker-php-ext-install soap
RUN docker-php-ext-install xsl
RUN docker-php-ext-install zip
RUN docker-php-ext-install opcache
RUN docker-php-ext-install sockets
RUN printf "\n" | pecl install imagick && docker-php-ext-enable imagick

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
# tag: agomezguru/drupal:9.x-php8.1.x
# Example: docker build . --tag agomezguru/drupal:9.x-php8.1.x

# If you desire use this Docker Image directly, uncomment the next line. 
# CMD php-fpm -F

# End of file
