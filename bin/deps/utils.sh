#!/usr/bin/env bash

print_and_run () {
    echo "Running ${BLUE}$@${RESET}"
    eval "$@"
}

# Colors
RESET="$(tput sgr0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"

# Magento
MAGENTO_ROOT="./src/"
MAGENTO_COMMAND="docker-compose run --rm cli bin/magento"
