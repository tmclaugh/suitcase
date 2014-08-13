#!/bin/sh -x

if [ "$AWS_TYPE" = "paravirt" ]; then
    console="console=hvc0"

    # CentOS 7 comes with GRUB 2 so we need to just create our own file.
    if [ "${os_version::1}" = "7" ]; then
        cat << EOF > /boot/grub/grub.conf
default=0
timeout=0

title CentOS Linux 7 ($(uname -r))
        root (hd0)
        kernel /boot/vmlinuz-$(uname -r) ro root=$(blkid /dev/sda1 | awk '{ print $3}' | sed 's/"//g') console=hvc0 LANG=en_US.UTF-8 elevator=noop
        initrd /boot/initramfs-$(uname -r).img
EOF

        chmod 0644 /boot/grub/grub.conf

     else
        # Our PV image is just a single partition.
        sed -i -e 's/\(hd0\),0/\1/' /boot/grub/grub.conf

        # Make sure we have xvda and not xvde.
        sed -i -e "s/\(kernel.*\)/\1 $console xen_blkfront.sda_is_xvda=1/" /boot/grub/grub.conf
    fi

    ln -fs /boot/grub/grub.conf /boot/grub/menu.lst

else
    console="console=ttyS0,115200n8 console=tty0"

    if [ "${os_version::1}" = "7" ]; then
        sed -i -e "s/\(GRUB_CMDLINE_LINUX.*\)\"/\1 $console\"/" /etc/default/grub
        grub2-mkconfig -o /boot/grub2/grub.cfg

    else
        sed -i -e "s/\(kernel.*\)/\1 $console/" /boot/grub/grub.conf
    fi
fi
