#!/bin/sh -x
#
# This script should be included by every build.

# Let cache be rebuilt when host starts.
yum clean all

# Delete guest additions uploaded by builder
if [ -f /tmp/VBoxGuestAdditions.iso ]; then
    rm /tmp/VBoxGuestAdditions.iso
fi

# Delete builder key.
echo > /root/.ssh/authorized_keys