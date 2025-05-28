# This container is intended to be used like base common place for the Drupal projects 
# currently only tested with 9 version.

# This Dockerfile was created 19/04/2021 for reuse the Docker build images more efficiently
# so, please don't be use directly. For more details see the comments at the end of this file. 
# Last updated: 10/03/2025 20:08 

# Use an official PHP runtime as a parent image.
# Ref.: https://www.drupal.org/docs/system-requirements/php-requirements
# Ref.: https://github.com/dooman87/imagemagick-docker

FROM php:8.4.8RC1-fpm

LABEL maintainer="Alejandro Gomez Lagunas <alagunas@coati.com.mx>"

ENV DEBIAN_FRONTEND=noninteractive

ARG IM_VERSION=6.9.11-60
#ARG LIB_HEIF_VERSION=1.18.2
#ARG LIB_AOM_VERSION=3.10.0
ARG LIB_WEBP_VERSION=1.4.0
#ARG LIBJXL_VERSION=0.11.0

# Install any needed packages and clear cache
RUN set=-eux pipefail; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y --no-install-recommends \
      git \
      ghostscript \
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
      ssh \
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
  docker-php-ext-install sockets; \
  docker-php-ext-install bcmath
  
  RUN apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y --no-install-recommends \
    make pkg-config autoconf curl cmake clang libomp-dev ca-certificates automake \
    # libaom
    yasm \
    # libheif
    libde265-0 libde265-dev libjpeg62-turbo libjpeg62-turbo-dev x265 libx265-dev libtool \
    # libwebp
    libsdl1.2-dev libgif-dev \
    # libjxl
    libbrotli-dev \
    # IM
    libpng16-16 libpng-dev libjpeg62-turbo libjpeg62-turbo-dev libgomp1 ghostscript libxml2-dev libxml2-utils libtiff-dev libfontconfig1-dev libfreetype6-dev fonts-dejavu liblcms2-2 liblcms2-dev libtcmalloc-minimal4 \
    # Install manually to prevent deleting with -dev packages
    libxext6 libbrotli1 && \
  export CC=clang CXX=clang++

# Building libwebp
RUN git clone -b v${LIB_WEBP_VERSION} --depth 1 https://chromium.googlesource.com/webm/libwebp && \
    cd libwebp && \
    mkdir build && cd build && cmake -DBUILD_SHARED_LIBS=ON ../ && make && make install && \
    ldconfig /usr/local/lib && \
    cd ../../ && rm -rf libwebp

# Building ImageMagick
RUN apt-get -y update && \
    apt-get -y upgrade && \
    git clone -b ${IM_VERSION} --depth 1 https://github.com/ImageMagick/ImageMagick6.git && \
    cd ImageMagick6 && \
    LIBS="-lsharpyuv" ./configure --without-magick-plus-plus --disable-docs --disable-static --with-tiff --with-jxl --with-tcmalloc && \
    make && make install && \
    ldconfig /usr/local/lib && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /ImageMagick

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions imagick/imagick@master && \
    docker-php-ext-enable imagick
    
RUN pecl install -o -f redis && \
    rm -rf /tmp/pear && \
    docker-php-ext-enable redis
    
# Install Composer
RUN curl -sS https://getcomposer.org/installer | \
  php -- --install-dir=/usr/local/bin --filename=composer

# Set your timezone here...
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Mexico_City /etc/localtime

# Database driver connection to percona.
RUN docker-php-ext-install pdo_mysql

# Add drush to cli
ENV PATH=/srv/bin:/srv/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /srv
# tag: agomezguru/drupal:10.x-php8.3.x
# Example: docker build . --tag agomezguru/drupal:10.x-php8.3.x
# Example: docker build --platform linux/amd64 --no-cache . --tag agomezguru/drupal:10.x-php8.3.17im

# If you desire use this Docker Image directly, uncomment the next line. 
# CMD php-fpm -F

# End of file
