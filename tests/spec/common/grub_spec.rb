# Common GRUB setup on all types

require 'spec_helper'

if os[:family] == 'RedHat7'
  describe file('/etc/default/grub') do
    it { should contain /kernel.*elevator=noop/ }
  end
else
  describe file('/boot/grub/grub.conf') do
    it { should contain /kernel.*elevator=noop/ }
    it { should contain /kernel.*printk.time=1/ }
  end
end
