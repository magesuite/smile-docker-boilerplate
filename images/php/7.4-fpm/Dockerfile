FROM php:7.4-fpm-alpine

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
        # xsl dev deps \
        libxslt-dev \
        # zip dev deps
        libzip-dev; \
    apk add --no-cache \
        # gd deps
        freetype libjpeg-turbo libpng libwebp libxpm \
        # intl deps \
        icu-libs \
        # xsl deps \
        libxslt \
        # zip deps \
        libzip; \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp --with-xpm; \
    docker-php-ext-install -j$(nproc) \
        bcmath \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        soap \
        sockets \
        xsl \
        zip; \
    apk del .build-deps

# Install dev tools (msmtp, xdebug)
RUN set -ex; \
    apk add --no-cache msmtp; \
    apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
    pecl install -o -f xdebug; \
    apk del .build-deps; \
    rm -rf /tmp/pear; \
    docker-php-ext-enable xdebug
COPY ./etc/msmtprc /etc/msmtprc

# PHP configuration
COPY ./etc/php.ini /usr/local/etc/php/conf.d/zz-magento.ini
COPY ./etc/php-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY ./etc/php-fpm.conf /usr/local/etc/

ENV MAGENTO_ROOT /var/www/html
WORKDIR $MAGENTO_ROOT
CMD ["php-fpm", "-F"]
