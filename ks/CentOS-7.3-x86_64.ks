# Kickstart file to build base CentOS 7 image

# CentOS-7.0-x86_64 - 201408131651:
lang en_US.UTF-8
keyboard --vckeymap=us
timezone --utc UTC
auth --useshadow --passalgo=sha256
selinux --disabled
firewall --disabled
firstboot --disable
text
reboot

rootpw --lock --iscrypted $1$0000000000000000000000000000000
# FIXME: Installer bug
# Add dummy user to keep installer from failing.
user --name=hsimage --plaintext --password hsimage

bootloader --location=mbr --timeout=1 --append="biosdevname=0 net.ifnames=0"
network --bootproto=dhcp --device=link --activate --onboot=on

# Partition Information. Change this as necessary
# This information is used by appliance-tools but
# not by the livecd tools.
#
zerombr
clearpart --all
ignoredisk --only-use=sda
# Leave room for disk partition info.
part / --grow --fstype xfs --label _/

# Repositories
#repo --cost=1000 --name=CentOS7-Base --mirrorlist=http://mirrorlist.centos.org/?release=7.0&arch=x86_64&repo=os
repo --cost=1000 --name=CentOS7-Updates --mirrorlist=http://mirrorlist.centos.org/?release=7.0&arch=x86_64&repo=updates

repo --cost=1000 --name=EPEL --baseurl=http://dl.fedoraproject.org/pub/epel/7/x86_64/
repo --cost=1 --name=Puppet-prod --baseurl=http://yum.puppetlabs.com/el/7/products/x86_64/
repo --cost=1 --name=Puppet-deps --baseurl=http://yum.puppetlabs.com/el/7/dependencies/x86_64/


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
screen
tmux
yum-utils
yum-plugin-changelog
yum-plugin-downloadonly
yum-plugin-ps

redhat-lsb

# Use standard NTP.
# FIXME: we have no NTP resource in Puppet which seems like a bad idea to me...
-chrony
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
facter-2.3.0-1.el7
puppet-3.7.3-1.el7

# This could be removed but would need a Puppet update to get keys from the
# internet.
epel-release

# Pulled in for Virtual Box.
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

# Ensure updates repo is disabled.
%post
yum-config-manager --disable updates
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
systemctl disable cloud-config
systemctl disable cloud-final
systemctl disable cloud-init
systemctl disable cloud-init-local
%end

# FIXME: Installer bug
# Delete dummy user we use to keep installer from failing.
%post
userdel hsimage
%end
