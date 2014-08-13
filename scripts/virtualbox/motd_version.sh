#!/bin/sh -x
#
# motd_version.sh

# Image versioning Info
#cat >> /etc/motd << EOF

echo "      _                             _"
echo "  ___| |_ _ __ __ _ _   _  ___ __ _| |_"
echo " / __| __| '__/ _  | | | |/ __/ _  | __|"
echo " \__ \ |_| | | (_| | |_| | (_| (_| | |_"
echo " |___/\__|_|  \__,_|\__, |\___\__,_|\__|"
echo "                    |___/"
echo " (base image, $vm_name / $kickstart)"

#EOF

cat >> /etc/straycat-base-image << EOF
$vm_name
EOF
