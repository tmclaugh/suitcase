#!/bin/sh

# ensure nscd is enabled for boot
if [ "${os_version::1}" == "7" ]; then
    systemctl enable nscd
else
    chkconfig nscd on
fi
