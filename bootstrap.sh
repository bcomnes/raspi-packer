#!/usr/bin/env bash

# bret-mbr:sbc-bootstrap bret$ ssh bret@192.168.1.12
set -e
set -x

# Recomended in https://wiki.archlinux.org/index.php/Chroot#Using_chroot
# Doesn't seem to do much
source /etc/profile
# Debug info
env

# First boot install step: https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
pacman-key --init
pacman-key --populate archlinuxarm

# Enable ntp
# TODO: can you do this with text?  timedatectl is not available in chroot
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
pacman -S git etckeeper --noconfirm --needed

export HOME=/root
git config --global user.email "bcomnes@gmail.com"
git config --global user.name "Bret Comnes"

etckeeper init

cd /etc
git add -A
git commit -m 'initial commit'

systemctl enable etckeeper.timer
systemctl start etckeeper.timer

# Set Hostname
# Normally we use hostnamectl, but that doesn't work in chroot
#hostnamectl set-hostname raspi3
echo raspi3 > /etc/hostname

# Install avahi and stuff
# TODO: Figure out if systemd has this built in now
pacman -S vim htop sudo avahi nss-mdns --noconfirm --needed

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
useradd -m bret
usermod -aG wheel bret
# delete default user alarm:alarm
# Comment out for debugability.
#userdel -r alarm
# disable root login root:root
# https://wiki.archlinux.org/index.php/Sudo#Disable_root_login
passwd -l root

mkdir /home/bret/.ssh

touch /home/bret/.ssh/authorized_keys
curl https://github.com/bcomnes.keys > /home/bret/.ssh/authorized_keys
chown -R bret:bret /home/bret/.ssh
chmod go-w /home/bret
chmod 700 /home/bret/.ssh
chmod 600 /home/bret/.ssh/authorized_keys

# restore original resolve.conf
mv /etc/resolv.conf.bk /etc/resolv.conf
