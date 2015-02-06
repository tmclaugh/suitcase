#!/bin/sh -x

# Set to publicly accesible nameserver
/bin/echo nameserver 8.8.8.8 > /etc/resolv.conf
/bin/echo nameserver 8.8.4.4 >> /etc/resolv.conf

# Make sure that DNS does not get updated by AWS.
sed -i -e 's/\(PEERDNS\)=yes/\1=no/' /etc/sysconfig/network-scripts/ifcfg-*
# Safety in case for some reason the installer doesn't set this.
for _nic in $(find /etc/sysconfig/network-scripts/ifcfg-* ! -name ifcfg-lo); do
    if ! egrep ^PEERDNS $_nic; then
        echo "PEERDNS=no" >> $_nic
    fi
done