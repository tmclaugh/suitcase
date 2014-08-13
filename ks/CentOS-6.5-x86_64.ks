# Kickstart file to build base CentOS 6 image

# CentOS-6.5-x86_64
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
repo --cost=1000 --name=CentOS6-Base --mirrorlist=http://mirrorlist.centos.org/?release=6.5&arch=x86_64&repo=os
# Disabled because it's a moving target. We also disabled is during post
# post via yum-config-manager because yum will use the newly created repo
# files and not this information from the kickstart.
#repo --cost=1000 --name=CentOS6-Updates --mirrorlist=http://mirrorlist.centos.org/?release=6.5&arch=x86_64&repo=updates
repo --cost=1000 --name=ELRepo-Kernel --baseurl=http://elrepo.org/linux/kernel/el6/x86_64/
repo --cost=1000 --name=CentOS6-Addons --mirrorlist=http://mirrorlist.centos.org/?release=6&arch=x86_64&repo=extras
repo --cost=1000 --name=EPEL --baseurl=http://dl.fedoraproject.org/pub/epel/6/x86_64/
repo --cost=500 --name=IUS --baseurl=http://dl.iuscommunity.org/pub/ius/stable/Redhat/6/x86_64/
# FIXME: SHould we use our own repo instead?
repo --cost=1 --name=Puppetlabs --baseurl=http://yum.puppetlabs.com/el/6/products/x86_64/
repo --cost=1 --name=Puppet-deps --baseurl=http://yum.puppetlabs.com/el/6/dependencies/x86_64/
#repo --name=percona --baseurl=http://repo.percona.com/centos/6/os/x86_64/

# Add all the packages after the base packages
%packages --nobase --instLangs=en
@core
system-config-securitylevel-tui
system-config-firewall-base # needed in order to disable selinux https://bugzilla.redhat.com/show_bug.cgi?id=547152
# FIXME: We need kernel packages newer than what's in the base in order to
# build the vbox guest additions.
kernel
kernel-devel
kernel-headers
audit
pciutils
bash
coreutils
grub
e2fsprogs
passwd
policycoreutils
chkconfig
rootfiles
yum
vim-minimal
acpid
openssh-clients
openssh-server
curl
ntp
redhat-lsb

# cloud-init
cloud-init
# XXX: Work around packaging error in EPEL
python-jsonpatch
python-jsonpointer


#Allow for dhcp access
dhclient
iputils

# Puppet
# We use our own mirror during cloud-init but we need the key from this
# package.
puppetlabs-release
facter-1.7.6-1.el6
puppet-3.6.2-1.el6
rubygems

# nscd helps us avoid a lot of problems with setting up
# ldap after puppet is running
nscd

# Setup for IUS
epel-release
ius-release

# Modules added from basenode
# see puppet/modules/basenode/manifests/init.pp
atop
ack
bc
bind-utils
dos2unix
dstat
emacs
file
finger
git
gnupg
gzip
htop
iftop
jwhois
lftp
lrzsz
lsof
lynx
man
mlocate
mutt
nano
nc
nss-pam-ldapd
openldap-clients
patch
psacct
rsync
s3cmd
screen
strace
subversion
sudo
sysstat
tcpdump
tcsh
telnet
traceroute
tmpwatch
tmux
unzip
vim-enhanced
vixie-cron
wget
wireshark
yum-utils
yum-plugin-replace
yum-plugin-downloadonly
zip

# Modules pulled in via other packages  found to be installed via
# /var/log/messages after a first puppet run
acl
xfsprogs
libmcrypt
python-pip
python-devel
python-virtualenv
libpcap
cyrus-sasl
postfix
libgomp
mailcap
gettext
mutt

# Pulled in with procserver and needed for Virtual Box.
gcc

# this is a funny section. install these only to replace them later
#mysql-libs

-bluez-libs
-cpuspeed
-dosfstools
-coolkey
-ccid
-GConf2
-gtk2
-hesiod
-irda-utils
-libnotify
-libwnck
-libXinerama
-mdadm
-mkbootdisk
-MySQL-shared-compat
-NetworkManager
-notification-daemon
-ORBit2
-pcmciautils
-pcsc-lite
-pcsc-lite-libs
-pinfo
-ppp
-rp-pppoe
-rsh
-sendmail
-talk
-unix2dos
-wpa_supplicant
-yp-tools
-ypbind

%end

%post
# Disable the updates repo.  (We're ensuring this is done first in post)
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
chkconfig cloud-config off
chkconfig cloud-final off
chkconfig cloud-init off
chkconfig cloud-init-local off
%end
