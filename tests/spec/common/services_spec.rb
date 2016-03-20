# Ensure any required services here.
require 'spec_helper'

if os[:family] != 'RedHat7'
  describe service('nscd') do
    it { should be_enabled }
  end
end