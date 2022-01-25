FROM php:7.4-fpm

# Install dependencies (php dev tools, sendmail)
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxslt1-dev \
    libzip-dev \
    libonig-dev \
    sendmail-bin \
    sendmail

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

# Install MailHog
RUN curl -L -O https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
    && chmod +x mhsendmail_linux_amd64 \
    && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail

ENV PHP_MEMORY_LIMIT 756M
ENV PHP_ENABLE_XDEBUG false
ENV MAGENTO_ROOT /var/www/html
ENV MAGENTO_RUN_MODE developer
ENV SENDMAIL_PATH /dev/null

# PHP configuration
COPY ./etc/mail.ini /usr/local/etc/php/conf.d/zz-mail.ini
COPY ./etc/php.ini /usr/local/etc/php/conf.d/zz-magento.ini
COPY ./etc/php-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini
COPY ./etc/php-fpm.conf /usr/local/etc/

COPY ./docker-entrypoint.sh /
RUN ["chmod", "+x", "/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]

WORKDIR ${MAGENTO_ROOT}
CMD ["php-fpm", "-F"]
