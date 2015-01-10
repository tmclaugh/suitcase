#!/bin/sh
#
# Download and install updated NIC drivers for SR-IOV.

cd ~/
wget http://elrepo.org/linux/elrepo/el6/x86_64/RPMS/kmod-ixgbe-3.23.2-1.el6.elrepo.x86_64.rpm
wget http://elrepo.org/linux/elrepo/el6/x86_64/RPMS/kmod-ixgbevf-2.14.2-1.el6.elrepo.x86_64.rpm

rpm -Uvh kmod-ixgbe*
