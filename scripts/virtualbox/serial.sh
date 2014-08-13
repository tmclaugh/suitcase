#!/bin/sh -x

# enable serial logging
echo 'ttyS0' >> /etc/securetty
echo 'S0:12345:respawn:/sbin/agetty ttyS0 115200' >> /etc/inittab
