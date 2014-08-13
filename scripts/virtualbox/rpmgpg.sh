#!/bin/sh -x

# Prevent rpm from complaining about GPG keys
cd /etc/pki/rpm-gpg/
for I in `ls`; do rpm --import $I; done;
cd -
