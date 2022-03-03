#!/usr/bin/env bash

# Do not run this script directly, it is a source file for the main setup script.

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
fi

if [ "${MAGENTO_EDITION}" == "cloud" ]; then
    # Choice: git repository
    echo -e "\n${RED}Warning:${RESET} Magento cloud projects must use the public packagist https://packagist.smile.fr, which requires an authenticated user account."
    echo "If you don't already have one, please ask dirtech@smile.fr to create an account for your project."

    if [ -z "${MAGENTO_GIT_URL}" ]; then
        [ "${NO_INTERACTION}" = "y" ] && echo "${RED}Missing git repository URL.${RESET}" && exit 1
        MAGENTO_GIT_URL=""
        ask_required_input MAGENTO_GIT_URL "Please specify the .git url (git@...) of your Magento Cloud project."
    fi

    MAGENTO_VERSION="${MAGENTO_VERSIONS[0]}"
    SMILE_PACKAGIST=public
else
    # Choice: Magento version
    if [ -z "${MAGENTO_VERSION}" ]; then
        MAGENTO_VERSION=""
        while
            ask_input MAGENTO_VERSION "Please choose the Magento version to use." ${DEFAULT_MAGENTO_VERSION}
            ! validate_magento_version "${MAGENTO_VERSION}" && echo "${RED}The magento version \"${MAGENTO_VERSION}\" is not valid.${RESET}"
        do true; done
    fi

    # Choice: Magento package repository
    if [ -z "${SMILE_PACKAGIST}" ]; then
        SMILE_PACKAGIST=""
        while
            ask_input SMILE_PACKAGIST "Please choose the Smile packagist repository to use (${BLUE}internal${GREEN} or ${BLUE}public${GREEN})." ${DEFAULT_SMILE_PACKAGIST}
            ! validate_smile_packagist "${SMILE_PACKAGIST}" && echo "${RED}The magento repository \"${SMILE_PACKAGIST}\" is not valid.${RESET}"
        do true; done
    fi
fi

# Set the composer repository URLs
MAGENTO_PACKAGIST_URL="https://packagist.galaxy.intranet/mirror/magento_official/" && [ "${SMILE_PACKAGIST}" = "public" ] && MAGENTO_PACKAGIST_URL="https://repo.magento.com/"
SMILE_PACKAGIST_URL="https://packagist.galaxy.intranet" && [ "${SMILE_PACKAGIST}" = "public" ] && SMILE_PACKAGIST_URL="https://packagist.smile.fr"

# Ask for packagist ACLs if public smile packagist was selected (optional values)
if [ "${SMILE_PACKAGIST}" = "public" ]; then
    if [ -z "${SMILE_PACKAGIST_USER}" ]; then
        [ "${NO_INTERACTION}" = "y" ] && echo "${RED}Missing Smile packagist ACL user.${RESET}" && exit 1
        SMILE_PACKAGIST_USER=""
        ask_required_input SMILE_PACKAGIST_USER "Please specify the Smile packagist Public ACL username to use."
    fi

    if [ -z "${SMILE_PACKAGIST_PASSWORD}" ]; then
        [ "${NO_INTERACTION}" = "y" ] && echo "${RED}Missing Smile packagist ACL password.${RESET}" && exit 1
        SMILE_PACKAGIST_PASSWORD=""
        ask_required_input SMILE_PACKAGIST_PASSWORD "Please specify the Smile packagist Public ACL password to use."
    fi
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
[ "${MAGENTO_EDITION}" = "cloud" ] && echo "- Magento git URL: ${BLUE}${MAGENTO_GIT_URL}${RESET}"
[ "${MAGENTO_EDITION}" != "cloud" ] && echo "- Magento version: ${BLUE}${MAGENTO_VERSION}${RESET}"
echo "- Packagist repository: ${BLUE}${SMILE_PACKAGIST_URL}${RESET}"
if [ "${SMILE_PACKAGIST}" = "public" ]; then
    echo "- Packagist ACL user: ${BLUE}${SMILE_PACKAGIST_USER}${RESET}"
    echo "- Packagist ACL password: ${BLUE}${SMILE_PACKAGIST_PASSWORD}${RESET}"
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
