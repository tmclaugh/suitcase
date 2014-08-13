#!/bin/sh -x
#
# In CentOS 7 kernel packages will generate an initramfs based on the
# drivers in use when the package is installed.  This means things like
# xen_blkfront (Xen block storage) will not be present as we build on
# VirtualBox.

if [ "${os_version::1}" = "7" ]; then
    dracut --force --add-drivers xen_blkfront /boot/initramfs-$(uname -r).img
fi