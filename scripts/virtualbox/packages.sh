#!/bin/sh
#

# A few packages
# FIXME: I don't think these are needed anymore.  Packages are installed in
# kickstart or don't appear to be neccesary any longer.
yum install -y openssh-ldap
yum install -y ruby-devel
yum install -y rubygems
