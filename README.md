## Update system
> First of all, update your system.

## Change your hostname
```
echo "yourhostname" >> /etc/hostname
```

# Workstation
**Packages to install and remove**
```
dnf install ibus ibus-bamboo qemu virt-manager dnsmasq vde2 dmidecode swtpm android-tools default-fonts-cjk gnome-tweaks flatseal btop neovim adw-gtk3-theme steam mangohud clang dmg2img thunderbird nextcloud-client jetbrains-mono-fonts-all ibm-plex-fonts-all vercel-geist-fonts --skip-unavailable && dnf remove gnome-connections gnome-maps mediawriter gnome-boxes yelp rhythmbox gnome-system-monitor nano gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list
```

# Silverblue
**Packages to install** 
```
rpm-ostree install ibus-bamboo qemu virt-manager dnsmasq vde2 dmidecode swtpm android-tools default-fonts-cjk gnome-tweaks btop neovim adw-gtk3-theme syncthing jetbrains-mono-fonts-all ibm-plex-fonts-all vercel-geist-fonts steam mangohud nextcloud-client 
```

**Packages to remove**
```
rpm-ostree override remove yelp gnome-system-monitor nano nano-default-editor default-editor gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list gnome-clasic-session
```

# Systemd service
```
sudo systemctl enable virtqemud virtnetworkd virtstoraged virtnwfilterd
```
  
## Electron Apps
> This is optional but I like wayland

```
nvim /etc/environment
```
```
EDITOR=/usr/bin/nvim
ELECTRON_OZONE_PLATFORM_HINT=auto
```

## Setup TPM2
**Check if tpm chip and secure boot be enable**
```
mokutil --sb-state
```
> If it show _SecureBoot enabled_. You good!
```
systemd-cryptenroll --tpm2-device=list
```
> If it show
```
PATH        DEVICE     DRIVER 
/dev/tpmrm0 NT....     tpm_...
```
> You also good!

**Find your encrypt UUID**
```
lsblk -pf /dev/nvme0n1
```

**Enroll TPM**
```
systemd-cryptenroll /dev/disk/by-uuid/encryptpartitionuuid --tpm2-pcrs=7 --tpm2-device=auto
```
> Replace encryptpartitionuuid with encrypt drive's UUID, usually it's _/dev/nvme0n1p3_ if you use ssd

**Update Grub**
```
grubby --update-kernel=ALL --args="rd.luks.options=tpm2-device=auto"
```
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Troubleshooting
**Nvidia** 
* When you first install or sometime update your system, there will be a mismatch between kernel and nvidia driver make it won't load. If that the case then use this command.
```
sudo akmods --force --rebuild
```

**Steam**
* If you have a low fps in vulkan games, for me like Counter Strike 2 despite the game use dedicated GPU as primary render instead of integrated GPU, use this command in Launch Option:
```
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json %command%
```

**Gnome**
* 'Log Out...' button dissappear?
```
gsettings set org.gnome.shell always-show-log-out true
```
