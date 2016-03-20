# Ensure SSH config.

require 'spec_helper'

describe file('/etc/ssh/sshd_config') do
  its(:content) { should match /^PermitRootLogin without-password/ }
end