# Homebrew formula to install our fork of ec2-ami-tools.
#
require 'formula'

class Ec2AmiTools < AmazonWebServicesFormula

  homepage 'https://git.hubteam.com/tmclaughlin/ec2-ami-tools'
  url 'git@git.hubteam.com:tmclaughlin/ec2-ami-tools.git', :using => :git

  def install
    standard_install
  end

  def caveats
    standard_instructions "EC2_AMITOOL_HOME"
  end
end
