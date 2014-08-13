#!/bin/sh -x

cat > /etc/cloud/cloud.cfg << EOF
system_info:
    distro: 'rhel'

disable_root: false

# This will cause the set+update hostname module to not operate (if true)
preserve_hostname: false

# The modules that run in the 'init' stage
cloud_init_modules:
 - migrator
 - bootcmd
 - resolv-conf
 - write-files
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - ca-certs
 - rsyslog
 - users-groups
 - ssh

# The modules that run in the 'config' stage
cloud_config_modules:
 - mounts
 - locale
 - set-passwords
 - package-update-upgrade-install
 - timezone
 - puppet
 - mcollective
 - runcmd

# The modules that run in the 'final' stage
cloud_final_modules:
 - scripts-per-once
 - scripts-per-boot
 - scripts-per-instance
 - scripts-user
 - ssh-authkey-fingerprints
 - keys-to-console
 - phone-home
 - final-message
 - power-state-change

EOF

