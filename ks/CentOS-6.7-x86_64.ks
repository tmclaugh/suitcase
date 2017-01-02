# Kickstart file to build base CentOS 6 image

# CentOS-6.7-x86_64
lang en_US.UTF-8
keyboard us
timezone --utc UTC
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
firstboot --disable
text
reboot

rootpw --lock --iscrypted $1$0000000000000000000000000000000

bootloader --location=mbr --timeout=1
network --bootproto=dhcp --device=eth0 --activate --onboot=on

zerombr
clearpart --all
ignoredisk --only-use=sda
part / --size 1 --grow --fstype ext4 --label _/

# Repositories
# The CentOS repos below will always end up with the latest minor version.
repo --cost=1000 --name=CentOS6-Base --mirrorlist=http://mirrorlist.centos.org/?release=6.7&arch=x86_64&repo=os
repo --cost=1000 --name=CentOS6-Updates --mirrorlist=http://mirrorlist.centos.org/?release=6.7&arch=x86_64&repo=updates

repo --cost=1000 --name=EPEL --baseurl=http://dl.fedoraproject.org/pub/epel/6/x86_64/
repo --cost=1 --name=Puppetlabs --baseurl=http://yum.puppetlabs.com/el/6/products/x86_64/
repo --cost=1 --name=Puppet-deps --baseurl=http://yum.puppetlabs.com/el/6/dependencies/x86_64/

# Add all the packages after the base packages
%packages
@core
@base
ack
dos2unix
dstat
git
htop
iftop
lynx
nc
nscd
# Use sssd eventually
nss-pam-ldapd
openldap-clients
rsync
s3cmd
tmux
yum-utils
yum-plugin-changelog
yum-plugin-downloadonly
yum-plugin-ps

redhat-lsb

# Use standard NTP.
# FIXME: we have no NTP resource in Puppet which seems like a bad idea to me...
ntp

# Install kernel related packages. Used for VBox Guest Additions.  Not sure
# if elsewhere.
kernel-devel
kernel-headers

# cloud-init
cloud-init

# Puppet
# We use our own mirror during cloud-init but we need the key from this
# package.
puppetlabs-release
facter-2.3.0-1.el6
puppet-3.7.3-1.el6


# This could be removed but would need a Puppet update to get keys from the
# internet.
epel-release

# needed for Virtual Box.
gcc

#NOTE: abrt may be worthwhile for kernel panics if we invest some time into
# learning and using it.
-abrt-*
-avahi
-crda
-dmraid
-fprintd-*
-hunspell-*
-ledmon
-libertas-*-firmware
-libreport-*
-libstoragemgmt
-lvm2
-iwl*-firmware
-ntsysv
-rubygem-abrt
-setuptool
-smartmontools
-usb_modeswitch-*
-yum-langpacks

%end

# The following is used by packer for provisioner actions.
%post
mkdir /root/.ssh
chmod 700 /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRsOlZeVl+R6EqwSPKRWMWNe8nXFAJQfV9ePyxo6HqTHUrf344yoLfe/yIgpea7vvIkc/L/SZuY6N4wazqIorbVLvKY4X+MUOAg9WS/mUr4SgtasZei7zu0DDK/rU/1/VIHYvk8UXCH89qxgyqdqmAgnk+1vfIGKr36aarZ+ognnvl4JgTJlmo27+sRzhU4ukCVno0kGLssv6IOH/K5Vp9eDXYZ12g77V90bY1OBzli9Eq6+cwZypQ9zurKg1bMWq5fwwS/x8Y7sssSGFojJcrqG+8Vh9HUNvSEikSpogYbdpSKfQjpa4g4pwJCMe4WUMVRpf8kb8/PLhiBNi5td6L Vagrant insecure key" > /root/.ssh/authorized_keys
chmod 644 /root/.ssh/authorized_keys
%end

# Disable cloud init.  It'll be reenabled by a provisioner if needed.
%post
chkconfig cloud-config off
chkconfig cloud-final off
chkconfig cloud-init off
chkconfig cloud-init-local off
%end
