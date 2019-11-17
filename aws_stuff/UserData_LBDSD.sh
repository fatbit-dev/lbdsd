#!/bin/bash

set -x

# Performs some fancy customizations for CENTUM developers convenience :)
EC2_USER="admin"
EC2_USER_HOME="/home/${EC2_USER}"
VIMRC_FILE="${EC2_USER_HOME}/.vimrc"
BASHRC_FILE="${EC2_USER_HOME}/.bashrc"
ETC_MOTD_FILE='/etc/motd' # For AWS EC2 Debian instances.
# SYSTEMD_SERVICE_NAME='lbdsd@'
# SYSTEMD_SERVICE_FILE="/etc/systemd/system/${SYSTEMD_SERVICE_NAME}.service"
# SYSTEMD_SERVICE_FILE_TARGET="/etc/systemd/system/multi-user.target.wants/${SYSTEMD_SERVICE_NAME}dev.service"

# Constructs a .vimrc file.
touch "${VIMRC_FILE}"
cat <<'FABI' >> "${VIMRC_FILE}"
syntax on
set tabstop=4
set hlsearch
set ruler
set mouse=nc
set pastetoggle=<F2>
set foldmethod=marker
set number
FABI

chown ${EC2_USER}:${EC2_USER} "${VIMRC_FILE}"

# Adds some aliases to .bashrc or .bash_profile.
touch "${BASHRC_FILE}"
cat <<'FABI' >> "${BASHRC_FILE}"

# Life is colors :)
export PS1="\[\033[01;32m\][dev] \[\033[01;37m\]\u\[\033[01;34m\]@\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\$ "
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
FABI

chown ${EC2_USER}:${EC2_USER} "${BASHRC_FILE}"

# Customizing MOTD.
cat > "${ETC_MOTD_FILE}" << 'FABI'
#!/bin/sh
cat << EOF

           Amazon Debian 9 Linux AMI

    ██╗     ██████╗ ██████╗ ███████╗██████╗ 
    ██║     ██╔══██╗██╔══██╗██╔════╝██╔══██╗
    ██║     ██████╔╝██║  ██║███████╗██║  ██║
    ██║     ██╔══██╗██║  ██║╚════██║██║  ██║
    ███████╗██████╔╝██████╔╝███████║██████╔╝
    ╚══════╝╚═════╝ ╚═════╝ ╚══════╝╚═════╝ 

    ---- Laboratorio de Bases de Datos ----
    ----    y Sistemas Distribuidos    ----

EOF
FABI

# Git repo.
GIT_CONFIG_FILE="${EC2_USER_HOME}/.gitconfig"
GIT_CONFIG_FILE_FOR_ROOT="/root/.gitconfig"
REPO_LBDSD="https://github.com/fatbit-dev/lbdsd.git"
REPO_URL="${REPO_LBDSD}"
REPO_BRANCH='develop'
REPO_TAGS="dev[0-9]"

# This is the directory where we will install our software.
DIR_DEPLOY_ROOT_SW="/lbdsd"
DIR_DEPLOY_BASE="${DIR_DEPLOY_ROOT_SW}/awe"
DIR_DEPLOY_NAME="/api"
DIR_DEPLOY="${DIR_DEPLOY_BASE}${DIR_DEPLOY_NAME}"

# CodeCommit git credentials: access keys and file paths.
# GIT_CMD="sudo -u ${EC2_USER} git"
# GIT_CMD="su ${EC2_USER} -c git"
DIR_AWS_CONFIG="${EC2_USER_HOME}/.aws"
FILE_AWS_GIT_CONFIG="${DIR_AWS_CONFIG}/config"
FILE_AWS_GIT_CREDENTIALS="${DIR_AWS_CONFIG}/credentials"
DIR_AWS_CONFIG_FOR_ROOT="/root/.aws"

# YaTT_EC2_User_Development.
AWS_CODECOMMIT_REGION="eu-west-1"
AWS_CODECOMMIT_FORMAT="json"
AWS_ACCESS_KEY="TODO: Fill the AWS Access Key ID"
AWS_SECRET_ACCESS_KEY="TODO: Fill the AWS Secret Access Key"

# PM2 user directory.
DIR_PM2_USER="${EC2_USER_HOME}/.pm2"

echo "====== APT UPDATE ======"
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt upgrade -y

echo "====== SETTING TIME ZONE ======"
# timedatectl set-timezone Etc/UTC
timedatectl set-timezone Europe/Madrid

# # If timedatectl is not available:
# rm -f /etc/localtime
# ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

echo "====== INSTALLING SOFTWARE ======"

cd /root/

echo "====== Base packages ======"
apt -y install \
    debian-keyring \
    build-essential \
    software-properties-common \
    zip unzip p7zip-full 

echo "====== Node.js 10 ======"
curl --silent --location https://deb.nodesource.com/setup_10.x | bash -
apt -y install nodejs
echo "====== Git ======"
apt -y install git
echo "====== Python 3 ======"
apt -y install python3
echo "====== Python PIP 3 ======"
apt -y install python3-pip
# echo "====== Python PIP 3 ======"
# apt -y install virtualenv

echo "====== AWS CLI to use CodeCommit ======"
python -m pip install --upgrade pip
python -m pip install awscli --upgrade --user
su ${EC2_USER} -c 'python -m pip install --upgrade pip'
su ${EC2_USER} -c 'python -m pip install awscli --upgrade --user'

echo "====== Python Virtualenv ======="
pip install https://github.com/pypa/virtualenv/archive/16.0.0.tar.gz --user

# Create or overwrite the AWSCLI config file.
mkdir -p "${DIR_AWS_CONFIG}"
cat > "${FILE_AWS_GIT_CONFIG}" << FAT
[default]
output = ${AWS_CODECOMMIT_FORMAT}
region = ${AWS_CODECOMMIT_REGION}

FAT

# Create or overwrite the AWSCLI credentials file.
cat > "${FILE_AWS_GIT_CREDENTIALS}" << FAT
[default]
aws_access_key_id = ${AWS_ACCESS_KEY}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

FAT

# Copy the files also to the root user home.
cp -r "${DIR_AWS_CONFIG}" "${DIR_AWS_CONFIG_FOR_ROOT}"
# Make the user own the files.
chown -R ${EC2_USER}:${EC2_USER} "${DIR_AWS_CONFIG}"

# Configure git and Credentials Helper to use AWS CodeCommit.
cat > "${GIT_CONFIG_FILE}" << 'FAT'
[credential]
UseHttpPath = true
# helper = !aws codecommit credential-helper $@

FAT

# Copy the file also to the root user home.
cp -r "${GIT_CONFIG_FILE}" "${GIT_CONFIG_FILE_FOR_ROOT}"
# Make the user owns the file.
chown ${EC2_USER}:${EC2_USER} "${GIT_CONFIG_FILE}"

echo "====== Setup of our deployment ======"
# Prepare the software deployment directory.
mkdir -p "${DIR_DEPLOY_BASE}"
chown -R ${EC2_USER}:${EC2_USER} "${DIR_DEPLOY_BASE}"

# Checkout the last software tag.
export HOME=/root
cd "${DIR_DEPLOY_BASE}"
git clone "${REPO_URL}" "${DIR_DEPLOY}"

cd "${DIR_DEPLOY}"
# GIT_LAST_TAG="$(git tag -l | grep "dev[0-9]*" | sort -r | head -n 1)"
# git checkout ${GIT_LAST_TAG}
git checkout ${REPO_BRANCH}
chown -R ${EC2_USER}:${EC2_USER} "${DIR_DEPLOY}"

# chmod +x ./bin/start.sh
# rm -r ./bin/db

chown -R ${EC2_USER}:${EC2_USER} "${DIR_DEPLOY}"

echo "====== PM2 ======"
npm install -g pm2

# echo "====== Create our systemd service configuration file ======"
# cat > "${SYSTEMD_SERVICE_FILE}" << FAT
# [Unit]
# Description=My_Prorgam
# After=network.target
# StartLimitIntervalSec=0

# [Service]
# # Type=simple
# Type=forking
# # Restart=always
# Restart=on-failure
# RestartSec=1
# User=${EC2_USER}
# # WorkingDirectory=${DIR_DEPLOY}
# ExecStart=${DIR_DEPLOY}/bin/start.sh %I

# [Install]
# WantedBy=multi-user.target

# FAT

# echo "====== Create PM2 directory for ${EC2_USER} ======"
# mkdir -p ${DIR_PM2_USER}
# chown -R ${EC2_USER}:${EC2_USER} "${EC2_USER_HOME}"
# chown -R ${EC2_USER}:${EC2_USER} "${DIR_PM2_USER}"

# echo "====== Enable and start our systemd service (PM2) ======"
# # systemctl enable ${SYSTEMD_SERVICE_NAME} # Does not work with instantiated services!
# ln -s "${SYSTEMD_SERVICE_FILE}" "${SYSTEMD_SERVICE_FILE_TARGET}"
# systemctl start "${SYSTEMD_SERVICE_NAME}dev"

# export HOME=${EC2_USER_HOME}
# echo "====== Change ownership of PM2 logs and data to ${EC2_USER} ======"
# chown -R ${EC2_USER}:${EC2_USER} "${EC2_USER_HOME}"
# chown -R ${EC2_USER}:${EC2_USER} "${DIR_PM2_USER}"

echo "====== CLEAN-UP ======"
apt clean
