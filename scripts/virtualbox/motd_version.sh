#!/bin/sh -x
#
# motd_version.sh

# Image versioning Info

echo "" > /etc/motd
echo "      _                             _"        >> /etc/motd
echo "  ___| |_ _ __ __ _ _   _  ___ __ _| |_"      >> /etc/motd
echo " / __| __| '__/ _, | | | |/ __/ _, | __|"     >> /etc/motd
echo " \__ \ |_| | | (_| | |_| | (_| (_| | |_"      >> /etc/motd
echo " |___/\__|_|  \__,_|\__, |\___\__,_|\__|"     >> /etc/motd
echo "                    |___/"                    >> /etc/motd
echo " (base image, $vm_name / $kickstart)"         >> /etc/motd
echo "" >> /etc/motd
echo "" >> /etc/motd

cat >> /etc/straycat-base-image << EOF

$vm_name

EOF
