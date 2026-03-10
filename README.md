## Update system
> First of all, update your system. Gui or terminal, it depend on you!

## Change your hostname
```
echo "yourhostname" >> /etc/hostname
```

# Workstation
**Packages to install and remove**
```
dnf install ibus ibus-bamboo qemu virt-manager swtpm android-tools default-fonts-cjk gnome-tweaks flatseal htop btop vim adw-gtk3-theme --skip-unavailable && dnf remove gnome-connections gnome-maps mediawriter gnome-boxes yelp rhythmbox gnome-system-monitor nano gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list
```

# Silverblue
**Packages to install** 
```
rpm-ostree install ibus-bamboo qemu virt-manager swtpm android-tools default-fonts-cjk gnome-tweaks btop vim adw-gtk3-theme vim-default-editor syncthing jetbrains-mono-fonts-all
```

**Packages to remove**
```
rpm-ostree override remove yelp gnome-system-monitor nano nano-default-editor default-editor gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list gnome-clasic-session
```

  
## Electron Apps
> This is optional but I like wayland

```
vim /etc/environment
```
```
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

**Print recovery**
> You gonna use this key to.. recover your luks device in case you being lock out
```
systemd-cryptenroll /dev/disk/by-uuid/encryptpartitionuuid --recovery-key
```
> It will show the key with dashes and keep it somewhere safe!

**Enroll TPM**
```
systemd-cryptenroll /dev/disk/by-uuid/encryptpartitionuuid --wipe-slot=empty --tpm2-device=auto
```
> Replace encryptpartitionuuid with encrypt drive's UUID, usually it's _/dev/nvme0n1p3_ if you use ssd

**Update Grub**
```
grubby --update-kernel=ALL --args="rd.luks.options=tpm2-device=auto"
```
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

**Troubleshooting**
* If you got a problem with nvidia drivers after first installed it like "NVIDIA kernel module missing. Falling back to nouveau", then just do this:
```
sudo akmods --force --rebuild
```

* If you have a low fps in vulkan games, for me like Counter Strike 2 despite the game use dedicated GPU as primary render instead of integrated GPU, use this command in Launch Option:
```
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.x86_64.json %command%
```
