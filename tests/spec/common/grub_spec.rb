# Common GRUB setup on all types

require 'spec_helper'

if os[:family] == 'RedHat7'
  describe file('/etc/default/grub') do
    its(:content) { should match /kernel.*elevator=noop/ }
  end
else
  describe file('/boot/grub/grub.conf') do
    its(:content) { should match /kernel.*elevator=noop/ }
    its(:content) { should match /kernel.*printk.time=1/ }
  end
end
