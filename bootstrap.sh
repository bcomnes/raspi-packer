# bret-mbr:sbc-bootstrap bret$ ssh bret@192.168.1.12
set -e
set -x

# Recomended in https://wiki.archlinux.org/index.php/Chroot#Using_chroot
source /etc/profile

# First boot install step: https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
pacman-key --init
pacman-key --populate archlinuxarm

# TODO: can you do this with text?
# timedatectl set-ntp true

# Enable network connection
## TODO double check this is restored on boot
rm -f /etc/resolv.conf
echo 'nameserver 8.8.8.8' > /etc/resolv.conf
pacman -Sy --noconfirm --needed

# Set up localization https://wiki.archlinux.org/index.php/Installation_guide#Localization
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

# Etckeeper init
pacman -S git etckeeper --noconfirm --needed

env

export HOME=/root
# TODO: This doesn't work in chroot
git config --global user.email "bcomnes@gmail.com"
git config --global user.name "Bret Comnes"
#
# This is a guess workaround
#cat > /root/.gitconfig <<- EOM
#[user]
#  email = bcomnes@gmail.com
#  name = Bret Comnes
#EOM

etckeeper init

# Doesn't work
#cd /etc
#git add -A
#git commit -m 'initial commit'

systemctl enable etckeeper.timer
systemctl start etckeeper.timer

# Set Hostname
# TODO: Usually do this, but it doesn't work
#hostnamectl set-hostname raspi3
# This is a guess workaround
echo raspi3 /etc/hostname

# Install avahi and stuff
# TODO: Figure out if systemd has this built in now
pacman -S vim htop sudo avahi nss-mdns --noconfirm --needed

# Set up sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel

# Set up avahi
systemctl enable avahi-daemon.service
sed -i 's/resolve/mdns_minimal [NOTFOUND=return] resolve/g' /etc/nsswitch.conf

# disable password auth
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd

# enable color on
# pacman
sed -i 's/#Color/Color/g' /etc/pacman.conf

# create user
useradd -m bret
usermod -aG wheel bret

sudo su - bret

cd /Users/bret
git clone https://github.com/bcomnes/.dotfiles
cd .dotfiles
pwd
ls -la
