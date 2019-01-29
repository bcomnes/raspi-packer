#!/bin/bash
# bret-mbr:sbc-bootstrap bret$ ssh bret@192.168.1.12
pacman-key --init
pacman-key --populate archlinuxarm
timedatectl set-ntp true

pacman -S git etckeeper --noconfirm --needed
git config --global user.email "bcomnes@gmail.com"
git config --global user.name "Bret Comnes"
etckeeper init
cd /etc
git add -A
git commit -m 'initial commit'
systemctl enable etckeeper.timer
systemctl start etckeeper.timer

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

hostnamectl set-hostname raspi3-1

pacman -S vim htop sudo avahi nss-mdns --noconfirm --needed

echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

systemctl enable avahi-daemon.service
sed -i 's/resolve/mdns_minimal [NOTFOUND=return] resolve/g' /etc/nsswitch.conf

sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd

sed -i 's/#Color/Color/g' /etc/pacman.conf
