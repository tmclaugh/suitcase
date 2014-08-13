#!/bin/sh -x

# disable root password based login
echo "PermitRootLogin without-password" >> /etc/ssh/sshd_config
# disable DNS lookups
echo "UseDNS no" >> /etc/ssh/sshd_config
