# Ensure any required services here.
require 'spec_helper'

describe service('cloud-config') do
  it { should be_enabled }
end

describe service('cloud-final') do
  it { should be_enabled }
end

describe service('cloud-init') do
  it { should be_enabled }
end

describe service('cloud-init-local') do
  it { should be_enabled }
end