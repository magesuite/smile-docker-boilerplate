FROM php:7.4-cli-alpine

# Install php extensions (dom and mbstring are already installed in the parent image)
RUN set -ex; \
    apk update; \
    apk add --no-cache --virtual .build-deps \
        # gd dev deps
        freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev libxpm-dev \
        # intl dev deps
        icu-dev \
        # soap dev deps
        libxml2-dev \
        # xlt dev deps \
        libxslt-dev \
        # zip dev deps
        libzip-dev; \
    apk add --no-cache \
        # gd deps
        freetype libjpeg-turbo libpng libwebp libxpm \
        # intl deps \
        icu-libs \
        # xlt deps \
        libxslt \
        # zip deps \
        libzip; \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install \
        bcmath \
        gd \
        intl \
        pcntl \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip; \
    apk del .build-deps

# Add dev tools (npp, grunt, shadow utils for usermod/groupmod, xdebug, smile certificates)
RUN set -ex; \
    apk update; \
    apk add --no-cache \
        npm \
        shadow; \
    npm install -g grunt-cli; \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
    pecl install -o -f xdebug; \
    apk del .build-deps; \
    rm -rf /tmp/pear; \
#    docker-php-ext-enable xdebug; \
    curl https://pki.smile.fr/smile2016.crt -so /usr/local/share/ca-certificates/smile.crt; \
    update-ca-certificates

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
COPY --from=composer:2 /usr/bin/composer /usr/bin/

# PHP configuration
COPY ./etc/php.ini /usr/local/etc/php/conf.d/zz-magento.ini
COPY ./etc/php-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY ./bin/* /usr/local/bin/

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

ENV MAGENTO_ROOT /var/www/html
WORKDIR $MAGENTO_ROOT
CMD ["sh"]
