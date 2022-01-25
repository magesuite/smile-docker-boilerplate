#!/bin/bash

# Update UID/GID
if [ -n "${UID}" ]; then
    usermod --uid $UID www-data
fi

if [ -n "${GID}" ]; then
    groupmod --gid $GID www-data
fi

# Substitute php.ini values
[ ! -z "${SENDMAIL_PATH}" ] && sed -i "s~!SENDMAIL_PATH!~${SENDMAIL_PATH}~" /usr/local/etc/php/conf.d/zz-mail.ini
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s~!PHP_MEMORY_LIMIT!~${PHP_MEMORY_LIMIT}~" /usr/local/etc/php/conf.d/zz-magento.ini

# Toggle Xdebug
[ "$PHP_ENABLE_XDEBUG" = "true" ] && \
    docker-php-ext-enable xdebug && \
    echo "Xdebug is enabled"

# Configure PHP-FPM
[ ! -z "${MAGENTO_RUN_MODE}" ] && sed -i "s~!MAGENTO_RUN_MODE!~${MAGENTO_RUN_MODE}~" /usr/local/etc/php-fpm.conf

exec "$@"
