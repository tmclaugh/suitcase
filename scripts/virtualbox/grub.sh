#!/bin/sh
#
# Alter grub setup.
#
if [ "${os_version::1}" == "7" ]; then
    sed -i -e 's/rhgb quiet/elevator=noop/' /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    sed -i -e 's/rhgb quiet/elevator=noop printk.time=1/' /boot/grub/grub.conf
fi
