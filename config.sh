#!/bin/sh

echo "-= Customizing Kali for th3r3g3nt =-"
cd /root

## Core updates ##
echo "[ ] Update && Upgrade"
apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
echo "[ ] Done."

## Kernel headers ##
echo "[ ] Installing kernel headers"
apt-get install -y linux-headers-$(uname -r)
echo "[ ] Done."

## Goodies ##
echo "[ ] Installing goodies"
apt-get -y install synaptic tuxcmd tuxcmd-modules libreoffice tor filezilla filezilla-common htop nethogs gtk-recordmydesktop recordmydesktop remmina unrar unace rar unrar p7zip zip unzip p7zip-full p7zip-rar file-roller curl ike-scan nikto john libssl-dev
echo "[ ] Done."

## Enable Metasploit at Startup ##
echo "[ ] Start MSF at startup"
update-rc.d postgresql enable
update-rc.d metasploit enable
