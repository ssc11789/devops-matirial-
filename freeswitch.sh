#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install build-essential curl git -y
sudo apt-get install wget libssl-dev libncurses5-dev libnewt-dev  libxml2-dev linux-headers-$(uname -r) libsqlite3-dev uuid-dev -y
sudo apt-get install libjansson-dev subversion -y
sudo apt-get remove firewalld
sudo apt-get remove iptables -y
sudo systemctl restart rsyslog
sudo apt-get update
sudo apt-get install -y xz-utils devscripts cowbuilder git screen
sudo apt-get update
cd /usr/src
wget -O - https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc | apt-key add -
echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" > /etc/apt/sources.list.d/freeswitch.list
echo "deb-src http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update
apt-get build-dep freeswitch -y
apt update
git clone https://freeswitch.org/stash/scm/fs/freeswitch.git -bv1.8 freeswitch
cd freeswitch/
git config pull.rebase true
./bootstrap.sh -j
./configure
make
make install
sed -i -r '28s/^#//;59s/^#//;122s/^#//;123s/^#//;162s/^#//;168s/^#//' modules.conf
make cd-sounds-install cd-moh-install
cd /usr/local
groupadd freeswitch
adduser --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH open source softswitch" --ingroup freeswitch freeswitch --disabled-password
chown -R freeswitch:freeswitch /usr/local/freeswitch/
chmod -R ug=rwX,o= /usr/local/freeswitch/
chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/*
#nano /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -i '/Wants/s/^/;/g' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -i '/Requires/s/^/;/g' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -ie 's/^After=.*/After=syslog.target network.target local-fs.target/' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -ie 's/^PIDFile=.*/PIDFile=\/usr\/local\/freeswitch\/run\/freeswitch.pid/' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed '12 a PermissionsStartOnly=true' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -i '/ExecStartPre/s/^/;/g' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed '15 a ExecStart=' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -ie 's/^ExecStart=.*/ExecStart=\/usr\/local\/freeswitch\/bin\/freeswitch -u freeswitch -g freeswitch -ncwait -nonat -rp/' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -ie 's/^Restart=.*/Restart=on-failure/' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed '19 a WorkingDirectory=/usr/local/freeswitch/bin' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
sed -i '/LimitSTACK/s/^/;/g' /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service
cp /usr/src/freeswitch/debian/freeswitch-systemd.freeswitch.service /etc/systemd/system/freeswitch.service
systemctl daemon-reload
systemctl start freeswitch
#journalctl -xe
#nano /etc/systemd/system/freeswitch.service
#nano /etc/systemd/system/freeswitch.service
systemctl daemon-reload
systemctl start freeswitch
systemctl enable freeswitch
systemctl status freeswitch.service
cd /usr/local/freeswitch/bin/
./fs_cli -rRS



