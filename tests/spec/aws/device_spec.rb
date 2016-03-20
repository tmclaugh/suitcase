# Device/modules for AWS.

require 'spec_helper'

describe command('lsinitrd') do
  its(:stdout) { should match /xen-blkfront.ko/ }
end