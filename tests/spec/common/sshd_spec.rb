# Ensure SSH config.

require 'spec_helper'

describe file('/etc/ssh/sshd_config') do
  it { should contain /^PermitRootLogin without-password/ }
end