#!/bin/sh
#
# Commands for ROM release
#

#set -e -o pipefail

DISTRIBUTION=$1
DISTRIB_RELEASE=$2
DISTRIB_TYPE=$3
DISTRIB_ARCH=$4
KHADAS_BOARD=$5
LINUX=$6
UBOOT=$7
INSTALL_TYPE=$8
VENDOR=$9

export LC_ALL=C
export LANG=C

# Setup password for root user
echo root:khadas | chpasswd

# Admin user khadas
useradd -m -p "pal8k5d7/m9GY" -s /bin/bash khadas
usermod -aG sudo,adm khadas

# Add group
DEFGROUPS="audio,video,disk,input,tty,root,users,games,dialout,cdrom,dip,plugdev,bluetooth,pulse-access,systemd-journal,netdev,staff"
IFS=','
for group in $DEFGROUPS; do
	/bin/egrep  -i "^$group" /etc/group > /dev/null
	if [ $? -eq 0 ]; then
		echo "Group '$group' exists in /etc/group"
	else
		echo "Group '$group' does not exists in /etc/group, creating"
		groupadd $group
	fi
done
unset IFS

echo "Add khadas to ($DEFGROUPS) groups."
usermod -a -G $DEFGROUPS khadas

# Setup host
echo Khadas > /etc/hostname
# set hostname in hosts file
cat <<-EOF > /etc/hosts
127.0.0.1   localhost Khadas
::1         localhost Khadas ip6-localhost ip6-loopback
fe00::0     ip6-localnet
ff00::0     ip6-mcastprefix
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
EOF

cd /

# MultiOS
if [ -f /.multi-os ]; then
	mkdir -p /home/khadas/.local/share/applications
	mkdir -p /home/khadas/.config/menus
	mv /*.menu /home/khadas/.config/menus
	mv /*.desktop /home/khadas/.local/share/applications
	mkdir -p /usr/share/multios/
	mv /*.png /usr/share/multios/
	chown khadas:khadas -R /home/khadas/.local
	chown khadas:khadas -R /home/khadas/.config
	rm -rf /.multi-os
fi

# Clean up
apt-get -y clean
apt-get -y autoclean
#history -c

# Self-deleting
rm $0
