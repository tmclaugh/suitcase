# GRUB on paravirt instances

require 'spec_helper'

describe file('/boot/grub/menu.lst') do
  it { should be_linked_to '/boot/grub/grub.conf' }
  it { should contain /kernel.*console=hvc0/ }
  it { should contain /root (hd0)/ }
  if os[:family] != 'RedHat7'
    it { should contain /kernel.* xen_blkfront.sda_is_xvda=1/}
  end
end