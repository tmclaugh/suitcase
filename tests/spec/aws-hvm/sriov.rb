# Ensure necessary setup for SR-IOV
require 'spec_helper'

describe package('kmod-ixgbevf') do
  it { should be_installed }
end