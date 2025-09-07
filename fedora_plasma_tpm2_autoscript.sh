#!/bin/bash

## This script was update in Aug-14-2025.

# Remind for system update
read -p "I assume that you already update your Fedora system before use this script? (Y/N) " prompt
if [[ ! "$prompt" =~ ^[Yy]$ ]]; then
	echo "OK, go update your system!"
	exit 1
fi

# Ask UUID
lsblk -o name,uuid
echo " "
echo "What is your luks drive UUID? Usually for fedora it's gonna be nvme0n1p3, nvme1n1p3, sda3 or any partition that *3."

read -p "UUID: " uuid

# Ask for hostname
echo "Name of your device?"

read -p "Device's name: " hostname

echo $hostname >> /etc/hostname

# Add flathub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# RPM Fusion
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

dnf config-manager setopt fedora-cisco-openh264.enabled=1

# Add 1Password repo
rpm --import https://downloads.1password.com/linux/keys/1password.asc
sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'

# Add Brave browser repo
dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

# Add Visual Code Studio repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

# Update and install essential packages
dnf update -y
dnf install fcitx5 fcitx5-qt fcitx5-gtk fcitx5-unikey kalk kclock merkuro haruna qemu virt-manager swtpm android-tools default-fonts-cjk thunderbird htop vim 1password brave-browser code -y

# Remove unnecessary packages
dnf remove mediawriter nano kcalc akregator dragon kaddressbook kfind kmahjongg kmail kmine kmouth kontact korganize kpatience neochat -y && sudo dnf autoremove -y

# Switch electron apps from XWayland to Wayland
echo "ELECTRON_OZONE_PLATFORM_HINT=auto" >> /etc/environment

# Create recovery keys
systemd-cryptenroll /dev/disk/by-uuid/$uuid --recovery-key | tee /home/$username/Documents/tpm2-keys.txt

echo " "
echo "Your TPM key will be save in your Documents directory and the file name will be 'tpm2-keys.txt'."
sleep 5
echo "Remember to save it somewhere safe!"
sleep 1

# Enroll TPM keys
systemd-cryptenroll /dev/disk/by-uuid/$uuid --wipe-slot=empty --tpm2-device=auto < /home/$username/Documents/tpm2-keys.txt

# Update Grub
grubby --update-kernel=ALL --args="rd.luks.options=tpm2-device=auto"
grub2-mkconfig -o /boot/grub2/grub.cfg

# Update crypttab file
sed -i "s/discard/tpm2-device=auto" /etc/crypttab

# Add and update initramfs file
echo 'add_dracutmodules+=" tpm2-tss "' > /etc/dracut.conf.d/tpm2.conf
dracut -vf
