# Ensure any required packages here.
require 'spec_helper'

# We don't want this enabled in the image so that we can rebuild the same
# image anytime but we do enable it after the host spins up.
#
# This will change after we start managing repos.
#

describe package('puppet') do
  it { should be_installed.with_version('3.7.3') }
end

describe package('facter') do
  it { should be_installed.with_version('2.3.0') }
end
