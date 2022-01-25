#!/bin/bash

# Update UID/GID
if [ -n "${UID}" ]; then
    usermod --uid $UID www-data
fi

if [ -n "${GID}" ]; then
    groupmod --gid $GID www-data
fi

# Update crontab
if [ ! -z "${CRONTAB}" ]; then
    echo "${CRONTAB}" > /etc/cron.d/magento && touch /var/log/cron.log
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
