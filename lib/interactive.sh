#!/usr/bin/env bash

# Do not run this script directly, it is a source file for the main setup script.

validate_magento_edition () {
    [[ "$1" = "community" || "$1" = "enterprise" || "$1" = "cloud" ]]
}

validate_magento_version () {
    [[ " ${MAGENTO_VERSIONS[*]} " = *" $1 "* ]]
}

validate_answer () {
    [[ "$1" = "y" || "$1" = "n" ]]
}

ask_input() {
    unset RESULT
    QUESTION=$2
    DEFAULT_VALUE=$3

    if [ "${NO_INTERACTION}" != "y" ]; then
        echo -e "\n${GREEN}${QUESTION}${RESET}"
        read -p "[${BLUE}${DEFAULT_VALUE}${RESET}] " RESULT
    fi

    if [ -z "${RESULT}" ]; then
        RESULT=${DEFAULT_VALUE}
    fi

    eval "$1='$RESULT'"
}

ask_required_input () {
    unset RESULT
    QUESTION=$2

    if [ "${NO_INTERACTION}" != "y" ]; then
        while
            echo -e "\n${GREEN}${QUESTION}${RESET}"
            read RESULT
            [ "$RESULT" = "" ] && echo "${RED}Please provide a value.${RESET}"
        do true; done

        eval "$1='$RESULT'"
    fi
}

ask_yes_no () {
    unset RESULT
    QUESTION=$2
    DEFAULT_VALUE=$3

    if [ "${NO_INTERACTION}" != "y" ]; then
        while
            echo -e "\n${GREEN}${QUESTION} (${BLUE}y${GREEN} or ${BLUE}n${GREEN})${RESET}"
            read -p "[${BLUE}${DEFAULT_VALUE}${RESET}] " RESULT
            if [ -z "${RESULT}" ]; then
                RESULT=${DEFAULT_VALUE}
            fi
            RESULT=$(echo ${RESULT} | tr 'A-Z' 'a-z')
            ! validate_answer "${RESULT}" && echo "${RED}You must choose between "y" or "n".${RESET}"
        do true; done

        eval "$1='$RESULT'"
    else
        eval "$1='$DEFAULT_VALUE'"
    fi
}

# Choice: Magento edition
if [ -z "${MAGENTO_EDITION}" ]; then
    MAGENTO_EDITION=""
    while
        ask_input MAGENTO_EDITION "Please choose the Magento edition to use (${BLUE}community${GREEN}, ${BLUE}enterprise${GREEN} or ${BLUE}cloud${GREEN})." ${DEFAULT_MAGENTO_EDITION}
        ! validate_magento_edition "${MAGENTO_EDITION}" && echo "${RED}The magento edition \"${MAGENTO_EDITION}\" is not valid.${RESET}"
    do true; done
elif ! validate_magento_edition ${MAGENTO_EDITION}; then
    echo -e "\n${RED}The magento edition \"${MAGENTO_EDITION}\" is not valid.${RESET}"
    exit 1
fi

if [ "${MAGENTO_EDITION}" == "cloud" ]; then
    # Choice: git repository
    echo -e "\n${RED}Warning:${RESET} Magento cloud projects must use the public packagist https://packagist.smile.fr, which requires an authenticated user account."
    echo "If you don't already have one, please ask dirtech@smile.fr to create an account for your project."

    # Prevent script execution if magento git URL is missing and interactive mode is disabled
    if [ "${NO_INTERACTION}" = "y" ]; then
        if [ -z "${MAGENTO_GIT_URL}" ]; then
            echo "${RED}Missing git repository URL.${RESET}"
            exit 1
        fi
    fi

    MAGENTO_GIT_URL=""
    ask_required_input MAGENTO_GIT_URL "Please specify the .git url (git@...) of your Magento Cloud project."

    MAGENTO_VERSION="${MAGENTO_VERSIONS[0]}"
    DEFAULT_MAGENTO_REPOSITORY=${DEFAULT_MAGENTO_REPOSITORY_CLOUD}
else
    # Choice: Magento version
    if [ -z "${MAGENTO_VERSION}" ]; then
        MAGENTO_VERSION=""
        while
            ask_input MAGENTO_VERSION "Please choose the Magento version to use." ${DEFAULT_MAGENTO_VERSION}
            ! validate_magento_version "${MAGENTO_VERSION}" && echo "${RED}The magento version \"${MAGENTO_VERSION}\" is not valid.${RESET}"
        do true; done
    elif ! validate_magento_version ${MAGENTO_VERSION}; then
        echo -e "\n${RED}The magento version \"${MAGENTO_VERSION}\" is not valid.${RESET}"
        exit 1
    fi
fi

# Choice: Magento repository
if [ -z "${MAGENTO_REPOSITORY}" ]; then
    MAGENTO_REPOSITORY=""
    ask_input MAGENTO_REPOSITORY "Please choose the Magento repository to use." ${DEFAULT_MAGENTO_REPOSITORY}
fi

# Ask for packagist ACLs if public smile packagist was selected (optional values)
if [[ "${MAGENTO_REPOSITORY}" = "${DEFAULT_MAGENTO_REPOSITORY_CLOUD}" && "${NO_INTERACTION}" != "y" ]]; then
    # Prevent script execution if packagist ACLs are missing and interactive mode is disabled
    if [ "${NO_INTERACTION}" = "y" ]; then
        if [ -z "${SMILE_PACKAGIST_USER}" ]; then
            echo "${RED}Missing Smile packagist ACL user.${RESET}"
            exit 1
        fi

        if [ -z "${SMILE_PACKAGIST_PASSWORD}" ]; then
            echo "${RED}Missing Smile packagist ACL password.${RESET}"
            exit 1
        fi
    fi

    SMILE_PACKAGIST_USER=""
    ask_required_input SMILE_PACKAGIST_USER "Please specify the Smile packagist Public ACL username to use."

    SMILE_PACKAGIST_PASSWORD=""
    ask_required_input SMILE_PACKAGIST_PASSWORD "Please specify the Smile packagist Public ACL password to use."
fi

# Choice: Smile modules
if [ -z "${SMILE_MODULES}" ]; then
    SMILE_MODULES=""
    ask_yes_no SMILE_MODULES "Please choose whether to install smile modules: cron, indexer, patch, reconfigure, varnish (${BLUE}y${GREEN} or ${BLUE}n${GREEN})." ${DEFAULT_SMILE_MODULES}
fi

# Choice: Smile tools
if [ -z "${SMILE_TOOLS}" ]; then
    SMILE_TOOLS=""
    ask_yes_no SMILE_TOOLS "Please choose whether to install smile tools: spbuilder, smileanalyser (${BLUE}y${GREEN} or ${BLUE}n${GREEN})." ${DEFAULT_SMILE_TOOLS}
fi

# Summary
echo -e "\n${GREEN}Summary${RESET}"
echo "- Magento edition: ${BLUE}${MAGENTO_EDITION}${RESET}"
echo "- Magento version: ${BLUE}${MAGENTO_VERSION}${RESET}"
echo "- Magento repository: ${BLUE}${MAGENTO_REPOSITORY}${RESET}"
if [ "${MAGENTO_REPOSITORY}" = "${DEFAULT_MAGENTO_REPOSITORY_CLOUD}" ]; then
    echo "    - Packagist ACL user: ${BLUE}${SMILE_PACKAGIST_USER}${RESET}"
    echo "    - Packagist ACL password: ${BLUE}${SMILE_PACKAGIST_PASSWORD}${RESET}"
fi
echo "- Smile modules: ${BLUE}${SMILE_MODULES}${RESET}"
echo "- Smile tools: ${BLUE}${SMILE_TOOLS}${RESET}"

# Confirm
if [ "${NO_INTERACTION}" != "y" ]; then
    echo -e "\n${GREEN}Please confirm the parameters with [${BLUE}y${GREEN}] or [${BLUE}n${GREEN}].${RESET}"
    read -p "  Confirm? " CONFIRM
    confirm=$(echo ${CONFIRM} | tr 'A-Z' 'a-z')
    if [ "${CONFIRM}" != "y" ]; then
        echo -e "\n${RED}Aborted by user.${RESET}"
        exit 1
    fi
fi
