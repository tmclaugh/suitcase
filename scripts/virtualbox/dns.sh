#!/bin/sh -x

# NOTE: NetworkManager will override this so see below.
# Set to publicly accesible nameserver
#/bin/echo nameserver 8.8.8.8 > /etc/resolv.conf

# Make sure that DNS does not get updated by AWS.
sed -i -e 's/\(PEERDNS\)=yes/\1=no/' /etc/sysconfig/network-scripts/ifcfg-*

for _nic in $(find /etc/sysconfig/network-scripts/ifcfg-* ! -name ifcfg-lo); do
    if ! egrep ^PEERDNS $_nic; then
        echo "PEERDNS=no" >> $_nic
    fi
    if ! egrep ^DNS1 $_nic; then
        echo "DNS1=8.8.8.8" >> $_nic
    fi
done
