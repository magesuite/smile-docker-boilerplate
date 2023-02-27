ARG PHP_VERSION=8.1
FROM registry.smile.fr/magento2/php:$PHP_VERSION-fpm-dev-2

# Install msmtp (for emails)
RUN apk add --no-cache msmtp
COPY ./etc/msmtprc /etc/

# PHP configuration
COPY ./etc/php.ini $PHP_INI_DIR/conf.d/zz-override.ini

# Add application user (more elegant than changing the uid of www-data, which is a system user)
ARG APP_UID=1000
ARG APP_GID=1000
RUN set -ex; \
    addgroup --gid "$APP_GID" www; \
    adduser --uid "$APP_UID" --ingroup www --disabled-password --gecos "" www

ENV CRON_USER=www
USER www

# Create directories that may be mounted as volumes (otherwise they would be created with root permissions)
RUN mkdir -p ~/.composer ~/.npm ~/.cache/yarn ~/.ssh
