# Device/modules for AWS.

require 'spec_helper'

describe command('lsinitrd') do
  it { should return_stdout /xen-blkfront.ko/ }
end