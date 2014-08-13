# Ensure any required services here.
require 'spec_helper'

describe service('nscd') do
  it { should be_enabled }
end