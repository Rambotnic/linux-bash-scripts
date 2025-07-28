#!/bin/bash

# Text colors
declare CLR_DEFAULT="\033[1;0m"
declare CLR_YELLOW="\033[1;33m"
declare CLR_CYAN="\033[1;36m"
declare CLR_GREEN="\033[1;32m"

displayInstallMessage() {
    echo -e "${CLR_YELLOW}"
    echo -e "\n=================================="
    echo -e " Installing $1 "
    echo -e "=================================="
    echo -e "${CLR_DEFAULT}"
}

installPkgs() {
    # Update existing packages first
    sudo dnf upgrade -y

    curlDownloads
    setupRepositories

    # Essential packages
    packages=(
        git
        zsh
        fzf
        fastfetch
        htop
        qdirstat
        bleachbit
        qalculate-qt
        vlc
        libavcodec-freeworld
        gimp
        audacity
        easytag
        autokey-qt
        openrgb
        mangohud
        goverlay
        discord
        steam
        virt-manager
    )

    for pkg in "${packages[@]}"; do
        declare isPkgNotInstalled=$(rpm -q $pkg 2>/dev/null | grep -c "is not installed")

        if [ $isPkgNotInstalled = 1 ]; then
            displayInstallMessage $pkg
            sudo dnf install $pkg -y
            sleep 1
        fi
    done

    sleep 1

    installGraphicsDrivers
    removeDependencies
    setup

    echo -e "${CLR_GREEN}\nALL DONE! :)\n${CLR_DEFAULT}"
    echo "Some settings require a session restart to take effect."
    
    while true; do
        read -p "Would you like to restart your session now? (You can do this later if you want) [y/n]: " yn
        case $yn in
            [Nn]* ) exit;;
            [Yy]* ) sudo pkill -KILL -u $(whoami);;
            * ) echo -e "\nPlease select yes (Y) or no (N). ";;
        esac
    done
}

installGraphicsDrivers() {
    displayInstallMessage "graphics drivers"
    sleep 1

    gpuInfo=$(lspci | grep -i vga)

    if [[ $gpuInfo == *"NVIDIA Corporation"* ]]; then
        #====================================
        # https://rpmfusion.org/Howto/NVIDIA
        #====================================
        echo -e "${CLR_CYAN}NVIDIA GPU detected. Installing NVIDIA drivers...${CLR_DEFAULT}"
        sudo dnf install akmod-nvidia -y

        while true; do
            driver_version=$(modinfo -F version nvidia 2>/dev/null)

            if [[ -n "$driver_version" ]]; then
                echo -e "${CLR_GREEN}NVIDIA driver installed.${CLR_DEFAULT}"
                break
            else
                echo -e "${CLR_YELLOW}kmod is being built. DO NOT CLOSE THIS WINDOW!.${CLR_DEFAULT}"
                echo "Checking again in 10 seconds..."
                sleep 10
            fi
        done
    elif [[ $gpu_info == *"Advanced Micro Devices"* ]]; then
        echo -e "${CLR_CYAN}AMD GPU detected. Installing AMD drivers...${CLR_DEFAULT}"

        # They are included in Fedora by default, but might as well double check
        sudo dnf install mesa-vulkan-drivers
    else
        echo "No NVIDIA or AMD GPU detected."
    fi
}

curlDownloads() {
    sudo dnf install curl -y

    # Brave Browser
    displayInstallMessage "brave-browser"
    curl -fsS https://dl.brave.com/install.sh | sh

    # Zoxide (smarter `cd` command)
    displayInstallMessage "zoxide"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

    # Neovim
    displayInstallMessage "neovim"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz

    if [ ! -d ~/.config/nvim/ ]; then
        mkdir ~/.config/nvim/
    fi
}

setupRepositories() {
    # Replace Fedora's flatpak repo with Flathub's
    flatpak remote-delete fedora && flatpak remote-delete fedora-testing
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

    # Enable RPM Fusion
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
}

removeDependencies() {
    echo -e "${CLR_YELLOW}"
    echo -e "=================================="
    echo -e " REMOVING UNUSED DEPENDENCIES...  "
    echo -e "=================================="
    echo -e "${CLR_DEFAULT}"
    sleep 1
    sudo dnf autoremove -y
    sudo dnf clean all
}

setup() {
    echo -e "${CLR_YELLOW}\n=================================="
    echo -e " Setting up a few things... "
    echo -e "==================================${CLR_DEFAULT}"
    sleep 1

    # Change Date & Time locale to British English and Numeric/Monetary locales to Brazilian Portuguese
    sudo localectl set-locale LC_TIME=en_GB.UTF8 LC_NUMERIC=pt_BR.UTF8 LC_MONETARY=pt_BR.UTF8

    # Move custom zsh files to the correct directory
    mv ../Shell\ Configs/.zsh* ~/

    # Set zsh to be the default shell
    declare username=$(whoami)
    declare zshDir=$(which zsh)
    sudo sed -i -e "s|root:/bin/bash|root:$zshDir|g" -e "s|$username:/bin/bash|$username:$zshDir|g" /etc/passwd

    # Enable the virtualization daemon and add user to libvirt group
    sudo systemctl enable --now libvirtd
    sudo usermod -a -G libvirt $USER
}

# Entry point
echo -e "\033]2;Install Essentials\007"

echo -e "This file will install essential packages on your computer and you will be prompted for your superuser password in order to do so."
echo -e "NOTE: Please make sure to run this file AFTER 'Remove Bloatware.sh'\n\n"
while true; do
    read -p "Do you wish to continue? [y/N]: " yn
    yn=${yn:-n}

    case $yn in
        [Nn]* ) exit;;
        [Yy]* ) installPkgs;;
        * ) echo -e "\nPlease select yes (Y) or no (N). ";;
    esac
done
