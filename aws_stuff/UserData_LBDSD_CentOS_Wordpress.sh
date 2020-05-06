#!/bin/bash

set -x

# Performs some fancy customizations for developers convenience :)
EC2_USER="ec2-user"
EC2_USER_HOME="/home/${EC2_USER}"
VIMRC_FILE="${EC2_USER_HOME}/.vimrc"
BASHRC_FILE="${EC2_USER_HOME}/.bashrc"
# ETC_MOTD_FILE='/etc/motd' # For AWS EC2 Debian instances.

# Constructs a .vimrc file.
touch "${VIMRC_FILE}"
cat <<'VIMRC' >> "${VIMRC_FILE}"
syntax on
set tabstop=4
set hlsearch
set ruler
set mouse=nc
set pastetoggle=<F2>
set foldmethod=marker
set number
VIMRC

chown ${EC2_USER}:${EC2_USER} "${VIMRC_FILE}"

# Adds some aliases to .bashrc or .bash_profile.
touch "${BASHRC_FILE}"
cat <<'BASHRC' >> "${BASHRC_FILE}"

# Life is colors :)
export PS1="\[\033[01;32m\][lbds] \[\033[01;37m\]\u\[\033[01;34m\]@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ "
#export LS_COLORS="di=36:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31:mi=0:ex=35"

# List files
alias ls='ls --color=auto --time-style=long-iso'
alias l='ls'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'

# Clear the screen
alias c='clear'
alias cls='clear && ls'

# Up 'n' folders
alias ..='cd ..'
alias ...='cd ../..'

# Colors in grep
alias grep='grep --color=auto'

# Some useful functions
ff () { find / -name "*$@*" ; }
ft () { grep -r "$@" ./ --color ; }

# Some helper aliases for PM2
pmi () { pm2 info "$@" ; }
pml () { pm2 log --lines=100 ; }

unset MAILCHECK

export PATH="/home/admin/bin:$PATH"
BASHRC

chown ${EC2_USER}:${EC2_USER} "${BASHRC_FILE}"


# CodeCommit git credentials: access keys and file paths.
# GIT_CMD="sudo -u ${EC2_USER} git"
# GIT_CMD="su ${EC2_USER} -c git"
DIR_AWS_CONFIG="${EC2_USER_HOME}/.aws"
FILE_AWS_GIT_CONFIG="${DIR_AWS_CONFIG}/config"
FILE_AWS_GIT_CREDENTIALS="${DIR_AWS_CONFIG}/credentials"
DIR_AWS_CONFIG_FOR_ROOT="/root/.aws"

# LBDSD_EC2_User_Development.
AWS_CODECOMMIT_REGION="eu-west-1"
AWS_CODECOMMIT_FORMAT="json"
AWS_ACCESS_KEY="TODO: Fill the AWS Access Key ID"
AWS_SECRET_ACCESS_KEY="TODO: Fill the AWS Secret Access Key"


echo "====== YUM UPDATE ======"
yum check-update
yum update -y

echo "====== SETTING TIME ZONE ======"
# timedatectl set-timezone Etc/UTC
timedatectl set-timezone Europe/Madrid

# # If timedatectl is not available:
# rm -f /etc/localtime
# ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

echo "====== INSTALLING SOFTWARE ======"

cd /root/

echo "====== Base packages ======"

echo "====== Node.js 10 ======"
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
yum install nodejs
echo "====== Git ======"
yum -y install git
echo "====== Python 3 ======"
yum -y install python3
echo "====== MariaDB Client ======"
yum -y install mariadb-client
#wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm  
#yum localinstall mysql57-community-release-el7-11.noarch.rpm
#yum install mysql-community-client 

echo "====== Apache HTTPd ======"
yum -y install httpd
amazon-linux-extras install –y php7.2 
yum -y install php-gd
systemctl start httpd 
systemctl enable httpd 
usermod -a -G apache ec2-user 
chown -R ec2-user:apache /var/www 
chmod 2775 /var/www && find /var/www -type d -exec chmod 2775 {} \; 
find /var/www -type f -exec sudo chmod 0664 {} \; 
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php 

export HOME=${EC2_USER_HOME}

echo "====== CLEAN-UP ======"
yum clean all
rm -rf /var/cache/yum

