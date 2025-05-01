#!/bin/bash

# Text colors
declare CLR_YELLOW="\033[1;33m"
declare CLR_DEFAULT="\033[1;0m"
declare CLR_GREEN="\033[1;32m"

removeSystemBloatware() {
	# Bloatware packages
	sysBloatware=(
		akregator*
		dragon*
		elisa*
		filelight*
		firefox*
		kaddressbook*
		kcalc*
		kmahjongg*
		kmail*
		kmines*
		kmouth*
		kontact*
		korganizer*
		kpat*
		krdc*
		neochat*
		skanpage*
	)

	# Loop through array and remove packages
	for pkg in "${sysBloatware[@]}"; do
		echo -e "${CLR_YELLOW}\n****************************"
		echo -e " Uninstalling $pkg "
		echo -e "****************************${CLR_DEFAULT}"
		sudo dnf remove $pkg -y
		sleep 1
	done
}

main() {
	echo -e "${CLR_YELLOW}==============================="
	echo -e " REMOVING BLOATWARE... "
	echo -e "===============================${CLR_DEFAULT}"
	sleep 2

	removeSystemBloatware

	echo -e "${CLR_YELLOW}\n==============================="
	echo -e " REMOVING DEPENDENCIES... "
	echo -e "===============================${CLR_DEFAULT}"
	sleep 2
	sudo dnf autoremove -y
    sudo dnf clean all

	echo -e "${CLR_GREEN}\nALL DONE! :)\n${CLR_DEFAULT}"

	# Pause execution
	read -p "" opt
	case $opt in
		* ) exit;;
	esac
}

echo -e "\033]2;Remove Bloatware\007"
echo -e "This file will remove a few pre-installed packages from your computer and you will be prompted for your superuser password in order to do so.\n\n"

while true; do
	read -p "Do you wish to continue? [y/n]: " yn
	case $yn in
		[Nn]* ) exit;;
		[Yy]* ) main;;
		* ) echo -e "\nPlease select yes (Y) or no (N). ";;
	esac
done
