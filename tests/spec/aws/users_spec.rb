# Users that should/should not exist

require 'spec_helper'

describe user('vagrant') do
  it { should_not exist }
end

# Make sure root's authorized_keys has been expunged.  Should be a single
# new line character.
describe file('/root/.ssh/authorized_keys') do
  it { should match_md5checksum('68b329da9893e34099c7d8ad5cb9c940') }
end