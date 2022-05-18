ARG PHP_VERSION=8.1
FROM registry.smile.fr/magento2/php:$PHP_VERSION-fpm as base

# Install git (for git clone and GrumPHP), msmtp and shadow utils (for usermod/groupmod)
RUN apk add --no-cache git msmtp shadow

# PHP dev configuration
RUN ln -sf $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
COPY ./etc/msmtprc /etc/
COPY ./etc/php-mail.ini $PHP_INI_DIR/conf.d/zz-mail.ini

# Binary files
COPY ./bin/run-cron /usr/local/bin/

FROM base as dev

# Install npm
RUN apk add --no-cache npm

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
    curl -sS https://getcomposer.org/installer | php -- --$COMPOSER_VERSION --install-dir=/usr/local/bin --filename=composer; \
    if [ "$COMPOSER_VERSION" = "1" ]; then composer global require --no-cache --no-plugins hirak/prestissimo; fi

# Add Smile certificates (required for https access to Smile packagist)
RUN set -ex; \
    curl https://pki.smile.fr/smile2016.crt -so /usr/local/share/ca-certificates/smile.crt; \
    update-ca-certificates

FROM base as xdebug

RUN set -ex; \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
    pecl install -o -f xdebug; \
    apk del .build-deps; \
    rm -rf /tmp/pear; \
    docker-php-ext-enable xdebug

COPY ./etc/php-xdebug.ini $PHP_INI_DIR/conf.d/zz-xdebug.ini
