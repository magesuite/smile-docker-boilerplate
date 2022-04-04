#!/bin/bash

# Update UID/GID
if [ -n "${DOCKER_UID}" ]; then
    usermod --uid $DOCKER_UID www-data
fi

if [ -n "${DOCKER_GID}" ]; then
    groupmod --gid $DOCKER_GID www-data
fi

# Substitute php.ini values
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s~!PHP_MEMORY_LIMIT!~${PHP_MEMORY_LIMIT}~" /usr/local/etc/php/conf.d/zz-magento.ini

# Toggle Xdebug
[ "$PHP_ENABLE_XDEBUG" = "true" ] && \
    docker-php-ext-enable xdebug && \
    echo "Xdebug is enabled"

# Configure composer
[ ! -z "${COMPOSER_GITHUB_TOKEN}" ] && \
    composer config --global github-oauth.github.com $COMPOSER_GITHUB_TOKEN

[ ! -z "${COMPOSER_MAGENTO_USERNAME}" ] && \
    composer config --global http-basic.repo.magento.com \
        $COMPOSER_MAGENTO_USERNAME $COMPOSER_MAGENTO_PASSWORD

exec "$@"
