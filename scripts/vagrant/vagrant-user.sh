#!/bin/sh -x
useradd -c "Vagrant" -d /home/vagrant -m -s /bin/bash -p $(openssl passwd -1 vagrant) vagrant

mkdir -p /etc/ssh/authorized_keys/vagrant
chmod 755 /etc/ssh/authorized_keys
chmod 700 /etc/ssh/authorized_keys/vagrant
chown vagrant:root /etc/ssh/authorized_keys/vagrant

mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chown vagrant:vagrant /home/vagrant/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCRsOlZeVl+R6EqwSPKRWMWNe8nXFAJQfV9ePyxo6HqTHUrf344yoLfe/yIgpea7vvIkc/L/SZuY6N4wazqIorbVLvKY4X+MUOAg9WS/mUr4SgtasZei7zu0DDK/rU/1/VIHYvk8UXCH89qxgyqdqmAgnk+1vfIGKr36aarZ+ognnvl4JgTJlmo27+sRzhU4ukCVno0kGLssv6IOH/K5Vp9eDXYZ12g77V90bY1OBzli9Eq6+cwZypQ9zurKg1bMWq5fwwS/x8Y7sssSGFojJcrqG+8Vh9HUNvSEikSpogYbdpSKfQjpa4g4pwJCMe4WUMVRpf8kb8/PLhiBNi5td6L Vagrant insecure key" | tee /etc/ssh/authorized_keys/vagrant/authorized_keys /home/vagrant/.ssh/authorized_keys

chmod 600 /etc/ssh/authorized_keys/vagrant/authorized_keys
chmod 644 /home/vagrant/.ssh/authorized_keys
chown vagrant:vagrant /etc/ssh/authorized_keys/vagrant/authorized_keys /home/vagrant/.ssh/authorized_keys

# Sudo setup
sed -i -e 's/^\s*\(Defaults\s*requiretty\).*$/# \1/g' /etc/sudoers
sed -i -e 's/^\s*\(Defaults\s*always_set_home\).*$/# \1/g' /etc/sudoers
echo 'Defaults    env_keep += "SSH_AUTH_SOCK"' >> /etc/sudoers
echo 'Defaults    env_keep += "HOME"' >> /etc/sudoers
echo 'vagrant ALL=(ALL)    NOPASSWD:ALL' >> /etc/sudoers
