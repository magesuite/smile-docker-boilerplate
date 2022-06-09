#!/usr/bin/env bash

# Do not run this script directly.

# Portable sed -i
sedi () {
    SEDI="sed -i"

    if [ $(uname) = "Darwin" ]; then
        SEDI="$SEDI ''" # Needed for portability with sed
    fi

    $($SEDI -e "$1" "$2")
}

# Compare two versions, returns "=", "<" or ">".
version_compare () {
    if [[ $1 == $2 ]]; then
        echo "="
        return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=0; i<${#ver1[@]}; i++)); do
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            echo ">"
            return
        elif ((10#${ver1[i]} < 10#${ver2[i]})); then
            echo "<"
            return
        fi
    done
    echo "="
}

# Colors
NC="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"

# Docker
DOCKER_COMPOSE="docker compose"
PHP_CONTAINER="php"
PHP_XDEBUG_CONTAINER="php_xdebug"
CRON_CONTAINER="cron"
