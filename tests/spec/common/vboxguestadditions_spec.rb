# Make sure Guest Additions are not installed.
require 'spec_helper'

describe file('/tmp/VBoxGuestAdditions.iso') do
  it { should_not be_file }
end

describe file('/root/VBoxGuestAdditions.iso') do
  it { should_not be_file }
end
