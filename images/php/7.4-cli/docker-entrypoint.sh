#!/bin/sh

# Configure composer
[ ! -z "$COMPOSER_GITHUB_TOKEN" ] && \
    composer config --global github-oauth.github.com $COMPOSER_GITHUB_TOKEN

[ ! -z "$COMPOSER_MAGENTO_USERNAME" ] && \
    composer config --global http-basic.repo.magento.com \
        $COMPOSER_MAGENTO_USERNAME $COMPOSER_MAGENTO_PASSWORD

exec "$@"
