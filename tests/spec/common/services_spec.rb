# Ensure any required services here.
require 'spec_helper'

if os[:family] == 'redhat' and os[:release] <= '7'
  describe service('nscd') do
    it { should be_enabled }
  end
end