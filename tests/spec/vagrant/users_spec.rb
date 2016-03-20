# Users that should/should not exist

require 'spec_helper'

describe user('vagrant') do
  it { should exist }
end

# Make sure root's authorized_keys has been expunged.  Should be a single
# new line character.
describe file('/root/.ssh/authorized_keys') do
  its(:sha256sum) { should eq '68b329da9893e34099c7d8ad5cb9c940' }
end