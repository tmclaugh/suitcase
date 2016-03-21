# GRUB on paravirt instances

require 'spec_helper'

describe file('/boot/grub/menu.lst') do
  it { should be_linked_to '/boot/grub/grub.conf' }
  its(:content) { should match /kernel.*console=hvc0/ }
  its(:content) { should match /root \(hd0\)/ }
  if os[:family] == 'redhat' and os[:release] <= '6'
    it { should contain /kernel.* xen_blkfront.sda_is_xvda=1/}
  end
end