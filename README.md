## Fedora-Config

# Update system
> First of all, update your system. Gui or terminal, it depend on you!

# Change your hostname
```
echo "yourhostname" >> /etc/hostname
```

# Packages to install
```
dnf install ibus ibus-bamboo qemu virt-manager swtpm android-tools default-fonts-cjk papers showtime gnome-tweaks flatseal htop vim adw-gtk3-theme gnome-shell-extension-connect
```
**Third party packages**
> **1password**
https://support.1password.com/install-linux/#fedora-or-red-hat-enterprise-linux
> **brave browser** if you don't browser-hop
https://brave.com/linux/#fedora-41-dnf5
> **visual studio code**
https://code.visualstudio.com/docs/setup/linux#_rhel-fedora-and-centos-based-distributions

# Packages to remove
```
dnf remove gnome-connections gnome-maps mediawriter gnome-boxes yelp totem rhythmbox evince gnome-system-monitor nano gnome-shell-extension-apps-menu gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu gnome-shell-extension-window-list
```

# Setup TPM2
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
systemd-cryptenroll --recovery-key
```
> It will show the key with dashes and keep it somewhere safe!

**Enroll TPM**
```
systemd-cryptenroll /dev/disk/by-uuid/encryptpartitionuuid
```
> Replace encryptpartitionuuid with encrypt drive's UUID, usually it's _/dev/nvme0n1p3_ if you use ssd

**Update Grub**
```
grubby --update-kernel=ALL --args="rd.luks.options=tpm2-device=/dev/tpmrm0"
```
```
grub-mkconfig -o /boot/grub2/grub.cfg
```

**Crypttab**
```
vim /etc/crypttab
```
> Edit
```
luks-****** UUID none tpm2-device=/dev/tpmrm0
```

**Update initramfs**
```
vim /etc/dracut.conf.d/tpm2.conf
```
Add 
```
add_dracutmodules+=" tpm2-tss "
```
> Exit file and update dracut
```
dracut -vf
```
