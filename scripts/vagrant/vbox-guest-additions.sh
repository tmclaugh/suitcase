#!/bin/sh -x
# Install VirtualBox Guest Additions

PACKAGES="gcc make perl"
VBOX_ISO_LOC="/tmp/VBoxGuestAdditions.iso"

yum -y install $PACKAGES

mount -o loop $VBOX_ISO_LOC /mnt
sh /mnt/VBoxLinuxAdditions.run --nox11
umount /mnt

cp /var/log/vboxadd-install.log /root