# Ensure disk setup.

require 'spec_helper'

# We require xfs on the root disk for 7 or else PV-GRUB fails to boot.  Doc
# says it should work but it did not.
if os[:family] != 'RedHat7'
  describe command('mount') do
    it { should return_stdout /\/dev\/sda1.*ext4/ }
  end
else
  describe command('mount') do
    it { should return_stdout /\/dev\/sda1.*xfs/ }
  end
end