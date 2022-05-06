ARG PHP_VERSION=8.1
FROM registry.smile.fr/magento2/php:$PHP_VERSION-fpm

# Install dev utils
RUN set -ex; \
    apk update; \
    apk add --no-cache msmtp npm shadow

# Install xdebug
RUN set -ex; \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
    pecl install -o -f xdebug; \
    apk del .build-deps; \
    rm -rf /tmp/pear; \
    docker-php-ext-enable xdebug
COPY ./etc/php-xdebug.ini $PHP_INI_DIR/conf.d/zz-xdebug.ini

# PHP dev configuration
RUN ln -sf $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
COPY ./etc/msmtprc /etc/
COPY ./etc/php-mail.ini $PHP_INI_DIR/conf.d/zz-mail.ini

# Install grunt
RUN set -ex; \
    npm install -g grunt-cli; \
    mkdir /tmp/npm; \
    chmod 777 /tmp/npm; \
    npm config -g set cache /tmp/npm

# Install composer
ARG COMPOSER_VERSION=2
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp/composer
RUN set -ex; \
    mkdir $COMPOSER_HOME; \
    chmod 777 $COMPOSER_HOME; \
    curl -sS https://getcomposer.org/installer | php -- --$COMPOSER_VERSION --install-dir=/usr/local/bin --filename=composer

# Add Smile certificates (required for https access to Smile packagist)
RUN set -ex; \
    curl https://pki.smile.fr/smile2016.crt -so /usr/local/share/ca-certificates/smile.crt; \
    update-ca-certificates

# Binary files
COPY ./bin/run-cron /usr/local/bin/
