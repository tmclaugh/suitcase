# Users that should/should not exist

require 'spec_helper'

# This user is created to workaround a CentOS 7 installer bug and should not
# be present in the final image
describe user('hsimage') do
  it { should_not exist }
end