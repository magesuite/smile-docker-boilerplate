#!/bin/bash

# Update UID/GID
if [ -n "${DOCKER_UID}" ]; then
    usermod --uid $DOCKER_UID www-data
fi

if [ -n "${DOCKER_GID}" ]; then
    groupmod --gid $DOCKER_GID www-data
fi

# Substitute php.ini values
[ ! -z "${SENDMAIL_PATH}" ] && sed -i "s~!SENDMAIL_PATH!~${SENDMAIL_PATH}~" /usr/local/etc/php/conf.d/zz-mail.ini
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s~!PHP_MEMORY_LIMIT!~${PHP_MEMORY_LIMIT}~" /usr/local/etc/php/conf.d/zz-magento.ini

# Toggle Xdebug
[ "$PHP_ENABLE_XDEBUG" = "true" ] && \
    docker-php-ext-enable xdebug && \
    echo "Xdebug is enabled"

exec "$@"
