Suitcase
=============
_Suitcase_ is for building OS images using [Packer](http://www.packer.io/)

_NOTE: You must alter site.rb to be applicable for your AWS environment_

Building
---------
Building images is a multi-step process using [Packer](http://www.packer.io/).  All work is performed on a developers local system.

## Setup
The process of building images requires:
* [VirtualBox](https://www.virtualbox.org/)
* [Packer](http://www.packer.io/)
* [ec2-ami-tools](https://aws.amazon.com/developertools/Amazon-EC2/368) (We maintain a fork patched to work on OS X)
* AWS IAM credentials to access S3.

### Install on OS X
* Install VirtualBox

* Install Packer
<pre>
$ brew install packer
</pre>

* install patched ec2-ami-tools
<pre>
$ brew install files/ec2-ami-tools.rb
</pre>

## Process
Suitcase uses a Rakefile to drive all Packer atcions.  The commands should be reasonably simple and intuitive.  All regularly needed actions can be achieved using the following tasks.  The optional _image_ argument is the name can be used to limit tasks to those for a particular image.  Without an image argument all images will have the specified action taken.  All actions require an _os_ argument (ex. os=CentOS-6.5-x86_64.json) to indicate the os template to be used.  A _timesstamp_ argument can optionally be supplied (ex. timestamp=201410031342).  The _timestamp_ is used to continue previous builds.

* rake packer:build[image]
    * Build an image artifact
* rake packer:upload[image]
    * Upload an image artifact to S3.
    * For EC2 images this does not bundle and register the AMI.
* rake packer:fake_upload[image]
    * Place upload cookie without actually uploading files to S3.  Useful for saving time when testing new AWS images by being able to skip this step and still do registration.
    * ONLY USE THIS FOR FACILITATING TESTING!!!
* rake packer:register[image]
    * Bundle and upload an image.
    * For EC2 images this is when an image the image is bundled, uploaded, and an AMI is registered.
* rake packer:all[image]
    * Build and upload images.
* rake packer:clean[image]
    * Cleans up the artifacts in the workspace.

There are additional tasks available and can be listed using _rake -T_.  These are typically used for developing and testing of new images and Suitcase itself.

### Example usage
The following is an example for how to create a new image for all types.  Note that the _register_ target is a second step.  Registration can be failure prone and it's useful to leave it till the end.
<pre>
$ rake packer:build os=CentOS-7.0-x86_64
$ rake packer:register os=CentOS-7.0-x86_64
</pre>

Build and register an AWS HVM image.  This will also build a new master image.
<pre>
$ rake packer:register[awshvm] os=CentOS-7.0-x86_64
</pre>

Build and register an AWS HVM image from an existing master.  This will also build a new master image.
<pre>
$ rake packer:build[master] os=CentOS-7.0-x86_64
(observe image timestamp from output. ex. 201410031904)
$ rake packer:register[awshvm] os=CentOS-7.0-x86_64 timestamp=201410031904
</pre>

Cleanup images when finished for build 201410031904.
<pre>
$ rake packer:clean os=CentOS-7.0-x86_64 timestamp=201410031904
</pre>

Cleanup a Vagrant image but leave others in place.  Possibly to regenerate only a single image again afterwards.
<pre>
$ rake packer:clean[vagrant] os=CentOS-7.0-x86_64 timestamp=201410031904
</pre>


Design
---
This repo provides a framework for building and testing OS images via Packer.  Packer aims to be a reliable way to create similar images for a variety of platforms through JSON based configuration files that define a build.  However it's process for building instance backed AWS paravirt images requires the use of an existing AWS instance backed AMI and violates constraints we have always maintained.  We have traditionally created our AMIs completely from scratch so that we retain full control and knowledge of the build process and what is installed on every image.  Additionally we also attempt to maintain image parity across platforms with the exception of changes required to handle platform specifics.  (ex. bootloader configuration, harddrive device naming)  Using Packer as intended would produce AWS HVM and AWS paravirt images that diverged from one another as the build processes are completely different.  The same goes for Vagrant images which would have been similar to AWS HVM images but divergent from paravirt images.

To solve these issues we use a multi-phase build process that builds an initial virtualbox VM that is then copied and reprocessed to create the AWS HVM, AWS paravirt, and Vagrant images.  The resulting images vary only slightly and make all three images fairly predictable to the end user.

## Repo Layout
* files/
    * Ancilary files for building images or using this repo.
* image-templates'
    * Packer templates for the different image formats to build for.
* images/
    * Images for different platforms.
    * Images are names in the format <os_build>-<timestamp>.
        * ex. _images/CentOS-7.0-x86_64-201409231340_
    * An image for a particular image type will be in _images/<type>_
        * Master: _images/master_
        * Vagrant: _images/vagrant_
        * AWS HVM: _images/aws-hvm_
        * AWS paravirt: _images/aws-paravirt
    * This location is controlled by the Packer build template
* ks/
    * Kickstart files for building master image.
    * These files should be versioned by X.Y (ex. 6.5, 6.6) so older images can be reproduced.
        * NOTE: We could change this and expect that older versions be reproduced by setting the repo to the commit point at time of build.  We'd need to record that.
* packer_cache/
    * Location where Packer stores objects like installation media.
* scripts/
    * Scripts to be run by templates during provisioners phase.  Scripts are not automatically run and must be specified in the build template.
    * The subdirectories under _scripts/_ correspond to the image type being built.  Scripts in _images/common/_ are meant to be executed by all or most image types.
* tests/
    * spec testing framework for image verification.
    * See below for more information on the testing framework.

## Packer templates
Packer is driven by JSON based templates.  This repo contains two types; image templates which are used to drive the build and OS templates which are used to define vars used by the image template.  The image template is the last argument passed to packer while the OS template is passed in via the __-var-file__ command.

<pre>
$ packer build -var-file=<os>.json <image>.json
</pre>

Examples:
* os template: CentOS-6.5-x86_64.json
* image template: vagrant.json

At the top of each image template is a section called _"variables"_ where all variables used in later sections must be defined.  Some have defaults already set.  (NOTE: timestamp has a default set to use the _timestamp_ macro from packer to facilitate testing.  The value is time since the Unix epoch and not the standard ISO-8601 format we use of YYYYMMDDhhmmss. ex. 201409221232  Always pass in a date from the command line using _'-var timestamp=<date>'_.)

The OS templates just contain values for the variables defined in the _"variables"_ section of the image template.  The process of adding a new OS version should start with simply creating a new OS template.  Packer allows values in var-files to be overridden on the command line using _'-var'_.

Example command for overriding the _headless_ option of a build.
<pre>
$ packer build -var-file=CentOS-7.0-x86_64.json -var headless=false virtualbox.json
</pre>

## Testing
This repo provides a [Serverspec](http://serverspec.org/) based testing framework to ensure that images conform to a desired specification.  The framework relies on two provisioners in the provisioner stage of the packer build.  One to upload this repo's _tests/_ directory and a second to execute _tests/serverspec.sh_ which will run the tests.

All image templates should have the following provisioners and executing _tests/serverspec.sh_ should be the final one.

Example:
```json
  "provisioners":
  [
    {
      "type"       : "file",
      "source"     : "tests",
      "destination": "/tmp"
    },
    {
      "type"             : "shell",
      "environment_vars" :
      [
        "IMAGE_TYPE={{user `image_type`}}",
        "AWS_TYPE={{user `aws_type`}}"
      ],
      "script"           : "tests/serverspec.sh"
    }
  ]

 ```

_NOTE: the values for the environmental vars are provided via variables defined in the "varibales" section of the image template._

All tests are in subdirectories under the _tests/spec/_ directory.  Tests in the _tests/common/_ directory will always be executed.  Setting the IMAGE_TYPE environmental variable will cause additional tests in _tests/spec/$IMAGE_TYPE_ to be executed.  By convention __"aws"__ is used for both HVM and paravirt images and AWS_TYPE is used to specify _tests/spec/aws-hvm_ or _tests/spec/aws-hvm_.


