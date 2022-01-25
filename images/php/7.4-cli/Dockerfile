FROM php:7.4-cli

ARG CRONTAB=""

# Configure Node.js version
RUN curl -sL https://deb.nodesource.com/setup_lts.x | bash

# Install dependencies (php dev tools, sudo for execution as www-data, curl/unzip for composer commands, nodejs)
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxslt1-dev \
    libzip-dev \
    libonig-dev \
    sudo \
    cron \
    curl \
    unzip \
    nodejs

# Configure the gd library
RUN docker-php-ext-configure \
    gd --with-freetype --with-jpeg

# Install required PHP extensions
RUN docker-php-ext-install \
    bcmath \
    dom \
    gd \
    intl \
    mbstring \
    pcntl \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip

RUN pecl install -o -f \
    xdebug \
    redis

RUN docker-php-ext-enable redis

ENV PHP_MEMORY_LIMIT 2G
ENV PHP_ENABLE_XDEBUG false
ENV MAGENTO_ROOT /var/www/html
ENV MAGENTO_RUN_MODE developer

# Install Grunt
RUN npm install -g grunt-cli

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_GITHUB_TOKEN ""
ENV COMPOSER_MAGENTO_USERNAME ""
ENV COMPOSER_MAGENTO_PASSWORD ""
RUN mkdir -p $COMPOSER_HOME/cache
COPY --from=composer:2 /usr/bin/composer /usr/bin/

# PHP configuration
COPY ./etc/php.ini /usr/local/etc/php/conf.d/zz-magento.ini
COPY ./etc/php-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY ./bin/* /usr/local/bin/

# Certificates
RUN curl https://pki.smile.fr/smile2016.crt -so /usr/local/share/ca-certificates/smile.crt \
    && update-ca-certificates

RUN ["chmod", "+x", "/usr/local/bin/magento-installer"]
RUN ["chmod", "+x", "/usr/local/bin/magento"]
RUN ["chmod", "+x", "/usr/local/bin/run-cron"]

COPY ./docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR ${MAGENTO_ROOT}
CMD ["bash"]
