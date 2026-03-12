#!/bin/bash

# Text colors
readonly CLR_DEFAULT="\033[1;0m"
readonly CLR_RED="\033[1;31m"
readonly CLR_YELLOW="\033[1;33m"
readonly CLR_GREEN="\033[1;32m"
readonly CLR_CYAN="\033[1;36m"

# Utility functions
logHeader() {
    echo -e "\n${CLR_YELLOW} > $1 "
    echo -e "-----------------------------------${CLR_DEFAULT}"
}

logInfo() {
    echo -e "\n${CLR_CYAN}$1${CLR_DEFAULT}"
}

logError() {
    echo -e "${CLR_RED}$1${CLR_DEFAULT}"
}

removeSystemBloatware() {
    logHeader "Removing system bloatware"

    declare -A BLOATWARE=(
        ["akregator*"]="Akregator"
        ["dragon*"]="Dragon Player"
        ["elisa*"]="Elisa"
        ["filelight*"]="Filelight"
        ["firefox*"]="Firefox"
        ["kaddressbook*"]="KAddressBook"
        ["kcalc*"]="KCalc"
        ["kmahjongg*"]="KMahjongg"
        ["kmail*"]="KMail"
        ["kmines*"]="KMines"
        ["kmouth*"]="KMouth"
        ["kontact*"]="Kontact"
        ["korganizer*"]="KOrganizer"
        ["kpat*"]="KPatience"
        ["krdc*"]="KRDC"
        ["neochat*"]="NeoChat"
        ["skanpage*"]="Skanpage"
    )

    readonly BLOATWARE

    for pkg in "${!BLOATWARE[@]}"; do
        logInfo ">>> Uninstalling ${BLOATWARE[$pkg]}"
        sudo dnf remove "$pkg" -y
    done

    logHeader "Cleaning up dependencies"
    sudo dnf autoremove -y
    sudo dnf clean all

    echo -e "${CLR_GREEN}\nFINISHED! :)\n${CLR_DEFAULT}"
    exit
}

setTitle() {
    echo -e "\033]2;Remove Fedora Bloatware\007"
}

main() {
    clear
    setTitle

    echo -e "This script will remove a few pre-installed packages from your computer and requires administrative (sudo) permissions."
    echo -e "${CLR_YELLOW}NOTICE:${CLR_DEFAULT} Running scripts from the internet can be dangerous. Please ensure you have audited and trust this script's code before proceeding.\n"

    while true; do
        read -p "Do you wish to continue? [y/N]: " yn
        yn=${yn:-n}

        case $yn in
            [Nn]* ) exit;;
            [Yy]* ) removeSystemBloatware;;
            * ) logError "\nPlease select YES (Y) or NO (N)";;
        esac
    done
}

main
