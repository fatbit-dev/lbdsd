#!/bin/bash

# Useful functions
error() {
  echo -e "\e[31m $@ \e[0m"
}

msg() {
    echo ''
    echo -e "\e[36m $@ \e[0m"
    echo ''
}


echo ''
echo '>>> ==============================='
echo '>>>             LBDSO              '
echo '>>>   ---------------------------  '
echo '>>>          System Setup          '
echo '>>> ==============================='
echo ''

if [[ $(id -u) -ne 0 ]]; then
    echo ''
    error '>>> Please, run with root privileges.'
    echo ''
    exit 1
fi

# First, setup software repositories, upgrade system and install some software.

msg 'Setting-up /etc/apt/sources.list'
EPOCH_MILLIS=$(( $(date '+%s%N') / 1000000 ));
cp /etc/apt/sources.list /etc/apt/sources.list_${EPOCH_MILLIS}
cat >/etc/apt/sources.list <<'SOURCESLIST'
deb http://httpredir.debian.org/debian buster main contrib non-free
deb-src http://httpredir.debian.org/debian buster main contrib non-free

deb http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free

deb http://deb.debian.org/debian buster-backports main contrib non-free
deb-src http://deb.debian.org/debian buster-backports main contrib non-free

# buster updates, previously known as 'volatile'
deb http://deb.debian.org/debian buster-updates main contrib non-free
deb-src http://deb.debian.org/debian buster main contrib non-free

# Docker
# deb [arch=amd64] https://download.docker.com/linux/debian buster stable

SOURCESLIST

msg '>>> Upgrading system software packages...'
apt -y update
apt -y upgrade

msg '>>> Installing additional software...'
apt -y install \
    bash-completion \
    zip \
    p7zip-full \
    debian-keyring \
    geany \
    geany-plugins \
    geany-plugin-addons \
    geany-plugins-common \
    vim \
    curl \
    wget

#msg 'Install add-apt-repository'
#apt -y install \
#    software-properties-common \
#    dirmngr \
#    apt-transport-https \
#    lsb-release \
#    ca-certificates

msg '>>> Installing gvfs for Thunar extra functionalities...'
apt -y install \
    gvfs \
    gvfs-fuse \
    gvfs-backends

msg '>>> Installing extra Xfce (GTK) icon themes...'
apt -y install \
    papirus-icon-theme \
    arc-theme \
    numix-gtk-theme \
    numix-icon-theme \
    numix-icon-theme-circle \
    moka-icon-theme

msg '>>> Installing rclone...'
curl https://rclone.org/install.sh | bash

msg '>>> Preparing VirtualBox Guest Additions dependencies...'
apt -y install \
	build-essential \
	dkms \
	linux-headers-$(uname -r) \
	module-assistant 

m-a prepare

# Now it's time to install VirtualBox Guest Additions
msg '>>> Please, insert VirtualBox Guest Additions ISO image.'
echo ''
echo '    You can do this from the VirtuaBox "Devices" configuration menu,'
echo '    and selecting "Insert Guest Additions CD image".'
echo ''
read -p '>>> Press ENTER to continue...'

cd /media/cdrom0/
ls -l
sh ./VBoxLinuxAdditions.run 

msg '>>> Please, add your regular (no root) user to the "vboxsf" group:'
echo '    Example:'
echo '         usermod -aG vboxsf fabi'

msg '>>> Please restart your system.'
exit 0
