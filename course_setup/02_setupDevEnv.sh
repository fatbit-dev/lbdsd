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
echo '>>>     Development Environment    '
echo '>>>              Setup             '
echo '>>> ==============================='
echo ''

if [[ $(id -u) -ne 0 ]]; then
    echo ''
    error '>>> Please, run with root privileges.'
    echo ''
    exit 1
fi

msg '>>> Increasing file limits...'
cat <<'PERUSERLIMITS' >> /etc/security/limits.conf
*  	    soft    nproc       65535
* 	    hard    nproc       65535
*	    hard	nofile		500000
*	    soft	nofile		500000
root	hard	nofile		500000
root	soft	nofile		500000
PERUSERLIMITS

msg '>>> Enabling PAM limits...'
echo -e "\nsession required pam_limits.so" >> /etc/pam.d/common-session

echo -e "\nfs.file-max = 2097152" >> /etc/sysctl.conf
sysctl -p

msg '>>> Upgrading system software packages...'
apt -y update
apt -y upgrade

msg '>>> Installing net-tools & lsof (netstat, ss, ...)'
apt -y install net-tools lsof

# Install MariaDB Server and Client
# The installation process will ask you a password for the root user.
# Please save this password and keep it secret.
msg '>>> Installing MariaDB...'
apt -y install \
    mariadb-server \
    mariadb-client

msg '>>> Checking MariaDB installation...'
apt policy mariadb-server

msg '>>> Checking MariaDB systemd service...'
systemctl status mariadb

msg '>>> Checking MariaDB port...'
echo '    Ports found:'
echo '>>> -- netstat ----------------'
netstat -ltnp | grep ':3306'
echo '>>> -- lsof -------------------'
lsof -i :3306 | grep LISTEN
echo '>>> ---------------------------'

msg '>>> Securing MariaDB installation...'
mysql_secure_installation

msg '>>> Trying to connect to local MariaDB service...'
mysql -u root -p

msg '>>> Installing git...'
apt -y install git gitk git-flow git-extras

msg ">>> Cloning course's git repo..."
cd
mkdir prj
cd prj
git clone https://github.com/fatbit-dev/lbdsd.git

msg '>>> Installing Java 11 (OpenJDK & OpenJRE)...'
apt -y install openjdk-11-jre openjdk-11-jdk
cat >> /etc/environment <<JAVAPATH
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
JAVAPATH

# apt -y install openjdk-8-jre openjdk-8-jdk
# cat >> /etc/environment <<JAVAPATH
# JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
# JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
# JAVAPATH

msg '>>> Checking Java version...'
java -version

msg '>>> Installing bat...'
wget -O /tmp/bat.deb \
    https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb
dpkg -i /tmp/bat.deb
rm /tmp/bat.deb

msg '>>> Installing VisualStudio Code...'
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
apt -y update
apt -y install code-insiders

msg '>>> Installing DBeaver CE...'
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
apt update
apt -y install dbeaver-ce

msg '>>> Checking DBeaver CE installation...'
apt policy dbeaver-ce 

msg '>>> Done!'

exit 0
