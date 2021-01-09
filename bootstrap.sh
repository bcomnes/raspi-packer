#!/usr/bin/env bash

# Run in a chroot context

set -e
set -x

hostname="${HOSTNAME}"
username="${USERNAME}"
github_keys="${GITHUB_KEYS}"
git_user_name="${GIT_USER_NAME}"
git_user_email="${GIT_USER_EMAIL}"

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
mv /etc/resolv.conf /etc/resolv.conf.bk
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
pacman -Sy --noconfirm --needed

# Set up localization https://wiki.archlinux.org/index.php/Installation_guide#Localization
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

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

# Set Hostname
# Normally we use hostnamectl, but that doesn't work in chroot
#hostnamectl set-hostname raspi3
echo "${hostname}" > /etc/hostname

# Install avahi and stuff
# TODO: Figure out if systemd has this built in now
pacman -S vim htop sudo avahi nss-mdns parted rng-tools --noconfirm --needed

# enable rng-tools
systemctl enable rngd.service
# disable software rng stuff
systemctl disable haveged.service

# Set up no-password sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# Set up avahi
systemctl enable avahi-daemon.service
sed -i 's/resolve/mdns_minimal [NOTFOUND=return] resolve/g' /etc/nsswitch.conf

# disable password auth
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
#systemctl restart sshd

# enable color on
# pacman
sed -i 's/#Color/Color/g' /etc/pacman.conf

# create user
useradd -m "${username}"
usermod -aG wheel "${username}"
# delete default user alarm:alarm
# Comment out for debugability.
userdel -r alarm
# disable root login root:root
# https://wiki.archlinux.org/index.php/Sudo#Disable_root_login
passwd -l root

# Setup user ssh keys
mkdir /home/"${username}"/.ssh
touch "/home/${username}/.ssh/authorized_keys"
curl "${github_keys}" > "/home/${username}/.ssh/authorized_keys"
chown -R "${username}:${username}" "/home/${username}/.ssh"
chmod go-w "/home/${username}"
chmod 700 "/home/${username}/.ssh"
chmod 600 "/home/${username}/.ssh/authorized_keys"

# restore original resolve.conf
mv /etc/resolv.conf.bk /etc/resolv.conf
