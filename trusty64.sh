#!/bin/bash

echo "updating repos ..."
apt-get update

echo "installing required tools ..."
apt-get install -y git curl

echo "setting vagrant sudoers file"
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "downloading vagrant ssh authorized keys ..."
mkdir -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys

echo "ensuring ssh correct permissions set ..."
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

echo "setting ssh configuration ..."
sed -i "0,/PubKeyAuthentication.*/s//PubKeyAuthentication yes/" /etc/ssh/sshd_config

echo "changing grub timer ..."
sed -i "0,/GRUB_TIMEOUT.*/s//GRUB_TIMEOUT 1/" /etc/default/grub
update-grub

echo "installing guest additions ..."
apt-get install -y build-essential linux-headers-server
mount /dev/cdrom /media/cdrom
/media/cdrom/VBoxLinuxAdditions.run
umount /media/cdrom

echo "fixing guest additions by linking ..."
ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions

echo "upgrading binaries ..."
apt-get upgrade -y

echo "cleaning logs and all ..."
apt-get autoremove -y
apt-get clean
rm -frv /tmp/*
rm -frv /var/log/wtmp /var/log/btmp

echo "reducing size of vm ..."
dd if=/dev/zero of=/EMPTY bs=1M
rm -frv /EMPTY

echo "clearing command history ..."
history -c

reboot
