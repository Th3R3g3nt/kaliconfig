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
apt-get -y install synaptic tuxcmd tuxcmd-modules libreoffice tor filezilla filezilla-common htop nethogs gtk-recordmydesktop recordmydesktop remmina unrar unace rar unrar p7zip zip unzip p7zip-full p7zip-rar file-roller curl ike-scan nikto john libssl-dev bridge-utils bettercap docker docker-compose curl virtualbox ncat apt-transport-https nload iftop metagoofil mingw-w64 pure-ftpd gcc-multilib g++-multilib libpcap-dev
echo "[ ] Done."

## Enable Metasploit at Startup ##
echo "[ ] Start MSF at startup"
update-rc.d postgresql enable
update-rc.d metasploit enable

## IPTables rule
echo "[ ] Installing firewall rules"
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -X LOGGING
iptables -N LOGGING

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -d 127.0.0.0/8 -i lo -j ACCEPT
iptables -A INPUT -s 192.168.0.0/16 -p tcp --dport 65022 -m state --state NEW -j ACCEPT
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
sed -i 's/^Port .*/Port 65022/g' /etc/ssh/sshd_config
sed -i 's/^ServerKeyBits .*/ServerKeyBits 8192/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin .*/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#Banner \/etc\/issue.net/Banner \/etc\/issue.net/g' /etc/ssh/sshd_config

echo "DebianBanner no" >>/etc/ssh/sshd_config
echo "Ciphers aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr,chacha20-poly1305@openssh.com" >>/etc/ssh/sshd_config
echo "HostKeyAlgorithms ssh-rsa,ssh-ed25519" >>/etc/ssh/sshd_config
echo "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512" >>/etc/ssh/sshd_config
echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com" >>/etc/ssh/sshd_config
/etc/init.d/ssh restart
echo "[ ] Done."

## CAL9000 ## Will replace it with cyberchef
#echo "[ ] Downloading CAL9000"
#cd /root
#mkdir Cal9000
#cd Cal9000
#wget -c -r --no-parent http://owasp-code-central.googlecode.com/svn/trunk/labs/cal9000/
#cd /root
#echo "[ ] Done."

## Veil Framework ## # Sorry, no longer the hot thing
#echo "[ ] Installing Veil Framework"
#cd /root
#git clone https://github.com/Veil-Framework/Veil.git
#cd Veil
#./config/setup.sh --force --silent
#cd /root
#echo "[ ] Done."

## Flash ##
#echo "[ ] Installing Flash"
#apt-get install flashplugin-nonfree
#update-flashplugin-nonfree --install
#echo "[ ] Done."

## Kubernetes
apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
touch /etc/apt/sources.list.d/kubernetes.list 
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc

curl -L https://github.com/kubernetes/kompose/releases/download/v1.1.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose

## Colon-replace ##
echo "[ ] Creating replace_colon script"
echo "rename 's|:|_|g' *" >replace_colon.sh
echo "[ ] Done."


## Replace issue.net ##
sed -i 's/^Kali .*/Unauthorized connection is prohibited by local, state, federal and\/or international laws. Do not proceed unless you are authorized by the Owner of this asset./g' /etc/issue.net

## Adding rsyslog tweaks
## SSH Monitoring
touch /var/log/sshd.log
echo "if $programname == 'sshd' then /var/log/sshd.log" >> /etc/rsyslog.conf
echo "& ~" >> /etc/rsyslog.conf

## Firewall Drops
touch /var/log/iptables-drop.log
echo "if $msg contains 'IPTables-Drop' then -/var/log/iptables-drop.log" >> /etc/rsyslog.conf
echo "& ~" >> /etc/rsyslog.conf

## PIP installs (native & Wine x86)
pip install pyinstaller
mkdir ~/.wine/drive_c/Python27
cd ~/.wine/drive_c/Python27
wget https://www.python.org/ftp/python/2.7.15/python-2.7.15.msi
wine msiexec /i python-2.7.15.msi 
wine python.exe -m pip install --upgrade pip
wine python.exe -m pip install pyinstaller
cd ~

## SI6 IPv6 Toolkit
cd ~
git clone https://github.com/fgont/ipv6toolkit.git
cd ipv6toolkit
make all
make install
cd ~

## GREP highligting
echo "alias grep='grep --color=auto'">>/root/.bashrc

## WebDav for the brave
pip install wsgidav cheroot

## Reminders ##
echo ""
echo "Done with the automated portion"
echo "!!! Don't forget Nessus !!!"
