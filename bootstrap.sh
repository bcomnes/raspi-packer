#!/usr/bin/env bash

# Run in a chroot context

set -e
set -x

hostname="${HOSTNAME}"
username="${USERNAME}"
github_keys="${GITHUB_KEYS}"
git_user_name="${GIT_USER_NAME}"
git_user_email="${GIT_USER_EMAIL}"
pi4_alt_fstab="${PI4_ALT_FSTAB}"
pi4_bootloader="${PI4_BOOTLOADER}"
pi5_bootloader="${PI5_BOOTLOADER}"
cm4_usb="${CM4_USB}"
lockdown_root="${LOCKDOWN_ROOT}"

# Recomended in https://wiki.archlinux.org/index.php/Chroot#Using_chroot
# Doesn't seem to do much
source /etc/profile
# Debug info
env

# First boot install step: https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
pacman-key --init
pacman-key --populate archlinuxarm

# Enable ntp
# Turns out this is on by default now
#timedatectl set-ntp true

# Enable network connection
if [[ -L /etc/resolv.conf ]]; then
  mv /etc/resolv.conf /etc/resolv.conf.bk;
fi
echo 'nameserver 8.8.8.8' > /etc/resolv.conf;
pacman -Syyu --noconfirm --needed
gpgconf --kill all

if [ "$pi4_bootloader" = "true" ] ; then
  pacman -R linux-aarch64 uboot-raspberrypi --noconfirm
  pacman -S linux-rpi raspberrypi-bootloader firmware-raspberrypi raspberrypi-utils --noconfirm --needed
fi

if [ "$pi5_bootloader" = "true" ] ; then
  pacman -R linux-aarch64 uboot-raspberrypi --noconfirm
  pacman -S linux-rpi-16k raspberrypi-bootloader firmware-raspberrypi raspberrypi-utils --noconfirm --needed
fi

# Set up localization https://wiki.archlinux.org/index.php/Installation_guide#Localization
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
echo 'LC_ALL=en_US.UTF-8' >> /etc/locale.conf

# Etckeeper init
pacman -S git etckeeper glibc --noconfirm --needed

export HOME=/root
git config --global user.email "${git_user_email}"
git config --global user.name "${git_user_name}"

etckeeper init

cd /etc
git add -A
git commit -m 'initial commit'

systemctl enable etckeeper.timer
systemctl start etckeeper.timer

# set up resize firstrun script
mv /tmp/resizerootfs.service /etc/systemd/system
chmod +x /tmp/resizerootfs
mv /tmp/resizerootfs /usr/sbin/
systemctl enable resizerootfs.service

# set up mac-host firstrun script
mv /tmp/mac-host.service /etc/systemd/system
chmod +x /tmp/mac-host
mv /tmp/mac-host /usr/sbin/
systemctl enable mac-host.service

# Set Hostname
# Normally we use hostnamectl, but that doesn't work in chroot
#hostnamectl set-hostname raspi3
echo "${hostname}" > /etc/hostname

# Install stuff
pacman -S vim htop parted sudo --noconfirm --needed

# Sometiems the network file is missing for some unknown reason
if [ ! -f "/etc/systemd/network/en.network" ] ; then
  echo 'Fixing eth -> en network file'
  touch /etc/systemd/network/en.network
  cat >/etc/systemd/network/en.network <<EOL
[Match]
Name=en*

[Network]
DHCP=yes
DNSSEC=no
EOL

fi

# Set up systemd-resolved  (mDNS)
mkdir -p /etc/systemd/resolved.conf.d
echo '[Resolve]' > /etc/systemd/resolved.conf.d/mdns.conf
echo 'MulticastDNS=yes' >> /etc/systemd/resolved.conf.d/mdns.conf
mkdir -p /etc/systemd/network/en.network.d
echo '[Network]' > /etc/systemd/network/en.network.d/mdns.conf
echo  'MulticastDNS=yes' >> /etc/systemd/network/en.network.d/mdns.conf

systemctl enable systemd-resolved.service

# disable password auth
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#systemctl restart sshd

# enable color on
# pacman
sed -i 's/#Color/Color/g' /etc/pacman.conf

# create user
useradd -m "${username}"
usermod -aG wheel "${username}"
usermod -aG video "${username}"

if [ "$lockdown_root" = "true" ] ; then
  # delete default user alarm:alarm
  userdel -r alarm
  # disable root login root:root
  # https://wiki.archlinux.org/index.php/Sudo#Disable_root_login
  passwd -l root
else
  # add alarm to sudo if its not deleted
  usermod -aG wheel "alarm"
fi

# copy the throttle script
mv /tmp/throttle.sh "/home/${username}/throttle.sh"
chmod +x "/home/${username}/throttle.sh"

# Setup user ssh keys
mkdir /home/"${username}"/.ssh
touch "/home/${username}/.ssh/authorized_keys"
curl "${github_keys}" > "/home/${username}/.ssh/authorized_keys"
chown -R "${username}:${username}" "/home/${username}/.ssh"
chmod go-w "/home/${username}"
chmod 700 "/home/${username}/.ssh"
chmod 600 "/home/${username}/.ssh/authorized_keys"

# Set up no-password sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

if [ "$pi4_alt_fstab" = "true" ] ; then
  echo 'setting up pi4 fstab'
  cat /etc/fstab
  sed -i 's/mmcblk0/mmcblk1/g' /etc/fstab
  cat /etc/fstab
fi

if [ "$cm4_usb" = "true" ] ; then
  echo '' >> /boot/config.txt
  echo '[cm4]' >> /boot/config.txt
  echo 'dtoverlay=dwc2,dr_mode=host' >> /boot/config.txt
fi

# restore original resolve.conf
if [[ -L /etc/resolv.conf.bk ]]; then
  mv /etc/resolv.conf.bk /etc/resolv.conf;
fi
