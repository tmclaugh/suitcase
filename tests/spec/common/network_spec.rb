# Network configuration

require 'spec_helper'

describe file('/etc/sysconfig/network-scripts/ifcfg-eth0') do
  it { should be_file }
end

# Ugly hack to get around vbox still using biosdevname on 7.0.  We fix it
# during provisioning so device name is correct when building subsequent
# images.  I didn't like having to copy this same test everywhere to work
# around one part of the build.
if ENV['IMAGE_TYPE'] != nil
  describe command('ip link show eth0') do
    it { should return_exit_status 0 }
  end
end