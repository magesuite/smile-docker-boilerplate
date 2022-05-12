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
RESET="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"

# Docker
DOCKER_COMPOSE="docker compose"
PHP_CONTAINER="php"
CRON_CONTAINER="cron"
