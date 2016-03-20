# GRUB on HVM instances

require 'spec_helper'

console="console=ttyS0,115200n8 console=tty0"

if os[:family] == 'redhat' and os[:release] >= '7'
  describe file('/etc/default/grub') do
    its(:content) { should match /GRUB_CMDLINE_LINUX.*#{console}/ }
  end
else
  describe file('/boot/grub/grub.conf') do
    its(:content) { should match /kernel.*#{console}/ }
  end
end