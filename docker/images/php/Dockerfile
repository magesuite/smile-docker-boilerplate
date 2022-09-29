ARG PHP_VERSION=8.1
FROM registry.smile.fr/magento2/php:$PHP_VERSION-fpm-dev-1

# Install msmtp (for emails)
RUN apk add --no-cache msmtp
COPY ./etc/msmtprc /etc/

# PHP configuration
COPY ./etc/php.ini $PHP_INI_DIR/conf.d/zz-override.ini

# Change app user id
ARG APP_UID=1000
ARG APP_GID=1000
RUN set -ex; \
    groupmod -g $APP_GID www-data; \
    usermod -u $APP_UID -g $APP_GID www-data

USER www-data

# Create directories that may be mounted as volumes (otherwise they would be created with root permissions)
RUN mkdir -p ~/.composer ~/.npm ~/.cache/yarn ~/.ssh
