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

## IPTables rule
echo "[ ] Installing firewall rules"
iptables -F
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -X LOGGING
iptables -N LOGGING

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -d 127.0.0.0/8 -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 65022 -m state --state NEW -j ACCEPT
iptables -A INPUT -j LOGGING

iptables -A FORWARD -s 127.0.0.0/8 -d 127.0.0.0/8 -i lo -j ACCEPT
iptables -A FORWARD -j LOGGING

iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Drop: " --log-level 4
iptables -A LOGGING -s 224.0.0.0/4 -j DROP
iptables -A LOGGING -p icmp -j DROP
iptables -A LOGGING -j DROP

iptables-save > /etc/iptables.rules
echo "#!/bin/sh" > /etc/network/if-pre-up.d/iptablesload
echo "iptables-restore < /etc/iptables.rules" >> /etc/network/if-pre-up.d/iptablesload
echo "exit 0" >> /etc/network/if-pre-up.d/iptablesload
chmod +x /etc/network/if-pre-up.d/iptablesload
iptables-restore < /etc/iptables.rules
echo "[ ] Done."

## SSH Port ##
echo "[ ] Configuring SSH"
/etc/init.d/ssh stop
sed -i 's/^Port .*/Port 65022/g' /etc/ssh/sshd_config
sed -i 's/^ServerKeyBits .*/ServerKeyBits 8192/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#Banner \/etc\/issue.net/Banner \/etc\/issue.net/g' /etc/ssh/sshd_config
echo "DebianBanner no" >>/etc/ssh/sshd_config
echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,arcfour" >>/etc/ssh/sshd_config
echo "MACs hmac-sha1,hmac-ripemd160,hmac-sha2-256,hmac-sha2-512" >>/etc/ssh/sshd_config
echo "[ ] Done."
