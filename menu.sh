#!/bin/bash

# BASH menu script that checks:

server_name=$(hostname)

function update_system() {
    echo ""
	echo "Updating System and add repo BlackArch ${server_name} is: "
	wget https://blackarch.org/strap.sh
	chmod +x strap.sh
	sudo ./strap.sh
	sudo pacman -Syyu
	sudo pacman -S --noconfirm yay
	yay -Syyu

	echo ""
}

function install_tools() {
    echo ""
	echo "Install System Tools ${server_name} is: "
    echo ""
	sudo pacman -S  git yay \
	neovim xclip zsh go screenfetch \
	p7zip unrar vlc flameshot xorg-xbacklight \
	zathura variety bat axel youtube-dl ctags \
	ranger speedtest-cli lolcat lsd unzip \
	transmission-gtk expac grub-customizer kitty tree exa
	#yay -S insomnia-bin vscodium-bin
    echo ""
}

function advanced_copy() {
    echo ""
	echo "Install 'Advanced Copy' Patch To Add Progress Bar To cp And mv Commands in Linux ${server_name}: "
    echo ""
	wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz
	tar xvJf coreutils-8.32.tar.xz
	cd coreutils-8.32/
	wget https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.8-8.32.patch
	patch -p1 -i advcpmv-0.8-8.32.patch && ./configure && make
	sudo cp src/cp /usr/local/bin/cp
	sudo cp src/mv /usr/local/bin/mv
	cd ../ && rm -rf core*
    echo "Cleaned!!!!!!!!"
}

function hacking_tools() {
    echo ""
	echo "Installing Hacking Tools ${server_name} is: "
	echo ""
	sudo pacman -S --noconfirm nmap wfuzz gobuster seclists netdiscover whatweb wafw00f
    echo ""
}

# 
function zsh_full() {
	echo ""

    sudo pacman -S --noconfirm zsh
	echo "Installing Oh-My-Zsh"
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	
	echo "Installing zsh-autosuggestions"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	
	echo "Install zsh-highlighting"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	
	echo "Installing  zsh-completions"
	git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

}

# Install npm and nodejs
function nodejs_npm() {
    echo ""
    echo "Installing NodeJS and NPM ${server_name} is: "
    echo ""
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    echo ""
    nvm install node
}

# Install Complete Installation of KVM, QEMU and Virt Manager on Arch Linux 

function_virtmanager_install() {

	echo "Installing KVM, QEMU and Virt Manager on Arch Linux"
	sudo pacman -S --noconfirm qemu virt-manager virt-viewer dnsmasq\
	vde2 bridge-utils openbsd-netcat ebtables iptables libguestfs
	sudo pacman -Syy
	sudo systemctl enable libvirtd.service
	sudo systemctl start libvirtd.service
	sudo vim /etc/libvirt/libvirtd.conf

	#
	sudo sed -i "86 iunix_sock_group = "libvirt"" /etc/libvirt/libvirtd.conf
	
	# Set the UNIX socket permissions for the R/W socket (around line 102)
	sudo sed -i "102 iunix_sock_rw_perms = "0770"" /etc/libvirt/libvirtd.conf

	# Add your user account to libvirt group.
	sudo usermod -a -G libvirt $(whoami)
	newgrp libvirt

	sudo systemctl restart libvirtd.service
	sudo modprobe -r kvm_intel
	sudo modprobe kvm_intel nested=1

	echo "options kvm-intel nested=1" | sudo tee /etc/modprobe.d/kvm-intel.
	
	# Linux -> KVM -> how to fix a Error starting domain: Requested operation is not valid: network ‘default’ is not active
	echo "Preventing error on boot Networking\n"
	echo "Error starting domain: internal error Network 'default' is not active."

	sudo virsh net-start default
	sudo virsh net-autostart default
	echo "Installions Done!!!!"

}

function install_docker() {
    if [ -x "$(command -v docker)" ]; then
        echo "Docker is already installed"
    else
        echo "Installing Docker"
        sudo pacman -S --noconfirm docker docker-compose
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker $USER
        sudo systemctl restart docker
        echo "Docker Installed"
    fi
}

# Color  Variables

green='\e[32m'
blue='\e[34m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

menu(){
echo -ne "
My First Menu
$(ColorGreen '1)') Update System And Add BlackArch Repo
$(ColorGreen '2)') Install Tools
$(ColorGreen '3)') Install advanced copy 
$(ColorGreen '4)') Install Virt Manager
$(ColorGreen '5)') Install Docker
$(ColorGreen '6)') Install Zsh
$(ColorGreen '7)') Install NodeJS and NPM
$(ColorGreen '8)') Check All
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) update_system ; menu ;;
	        2) install_tools ; menu ;;
	        3) advanced_copy ; menu ;;
	        4) function_virtmanager_install ; menu ;;
            5) install_docker ; menu ;;
            6) zsh_full ; menu ;;
            7) nodejs_npm ; menu ;;
	        8) all_checks ; menu ;;
	0) exit 0 ;;
		*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}

# Call the menu function
menu	
