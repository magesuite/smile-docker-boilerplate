#!/usr/bin/env bash

# Do not run this script directly.

# Ask user for an input value.
ask_input () {
    unset RESULT
    QUESTION=$2
    DEFAULT_VALUE=$3

    while
        printf "\n${GREEN}$QUESTION${RESET}\n"

        if [ -n "$DEFAULT_VALUE" ]; then
            read -p "[${BLUE}$DEFAULT_VALUE${RESET}] " RESULT
        else
            read RESULT
        fi

        if [ -z "$RESULT" ] && [ -n "$DEFAULT_VALUE" ]; then
            RESULT="$DEFAULT_VALUE"
        fi

        [ "$RESULT" = "" ] && echo "${RED}Please provide a value.${RESET}"
    do true; done

    eval "$1='$RESULT'"
}

# Ask user to choose between yes and no.
ask_yes_no () {
    unset RESULT
    QUESTION=$2
    DEFAULT_VALUE=$3

    while
        printf "\n${GREEN}$QUESTION (${BLUE}y${GREEN}/${BLUE}n${GREEN})${RESET}\n"

        if [ -n "$DEFAULT_VALUE" ]; then
            read -p "[${BLUE}$DEFAULT_VALUE${RESET}] " RESULT
        else
            read RESULT
        fi

        if [ -z "$RESULT" ] && [ -n "$DEFAULT_VALUE" ]; then
            RESULT="$DEFAULT_VALUE"
        fi

        RESULT=$(echo "$RESULT" | tr 'A-Z' 'a-z')
        [ "$RESULT" != "y" ] && [ "$RESULT" != "n" ] && echo "${RED}You must choose between "y" or "n".${RESET}"
    do true; done

    eval "$1='$RESULT'"
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

# Magento
DOCKER_COMMAND="docker compose run --rm cli"
