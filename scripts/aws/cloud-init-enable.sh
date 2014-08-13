#!/bin/sh -x
if [ "${os_version::1}" == "7" ]; then
    systemctl enable cloud-config
    systemctl enable cloud-final
    systemctl enable cloud-init
    systemctl enable cloud-init-local
else
    chkconfig cloud-config on
    chkconfig cloud-final on
    chkconfig cloud-init on
    chkconfig cloud-init-local on
fi