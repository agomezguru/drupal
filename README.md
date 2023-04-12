# Quick reference, Drupal

Configured PHP 8.1.x server for deploy Drupal 9.x based projects

- **Maintained by**:
[agomezguru](https://github.com/agomezguru)

- **Where to get help**:  
[Docker Official Images: php](https://hub.docker.com/_/php/)

## Supported tags and respective `Dockerfile` links

- [`9.x-php8.1.x`](https://github.com/agomezguru/drupal/tree/9.x-php8.1.x)
- [`latest`](https://github.com/agomezguru/drupal)

## How to use this image

The intent of this image is always being together use with a NGINX docker container and MySQL/MariaDB/Percona database with a simple `Dockerfile` (in `/host/path/`) like this one:

```bash
cat <<EOF > docker-compose.yml
version: '3'

volumes:
  my-public:
    external: true
  my-db-data:
    external: true

services:
  web:
    image: agomezguru/nginx:laravel-8x
    ports:
      - "8080:80"
    environment:
      - HOST_NAME=myAppHostName
      - LOG_STATUS=on
      - LOG_NAME=myAppLogName
      - DEPLOYMENT_STAGE=develop
      - PHP_CONTAINER_NAME=php
    volumes:
      - ../someCode:/var/www/html
      - my-public:/var/www/html/public
    networks:
      - my-network

  php:
    image: agomezguru/drupal:9.x-php8.1.x
    volumes:
      - ../someCode:/var/www/html
      - my-public:/var/www/html/public
      - ./php-composer.ini:/usr/local/etc/php/conf.d/custom.ini
    networks:
      - my-network

  db:
    image: percona:8.0
    volumes:
      - my-db-data:/var/lib/mysql
      - ../percona/masterdb/config:/etc/mysql/conf.d
      - ../backups:/dumps
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: someStrongPassword
    networks:
      - my-network

# Isolate docker containers arrays between environments.
networks:
  my-network:
    driver: bridge
EOF
```

### Using environment variables in PHP configuration

This container image doesn't support any environment variables.

## License

View [php license information](http://www.php.net/software/) and [Composer](https://github.com/composer/composer/blob/master/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
