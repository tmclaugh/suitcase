#!/bin/sh -x
echo "Performing spec tests."
sudo gem install bundler --no-ri --no-rdoc
cd /tmp/tests
bundle install --path=vendor

if [ ! -z $IMAGE_TYPE ]; then
    env IMAGE_TYPE=$IMAGE_TYPE AWS_TYPE=$AWS_TYPE bundle exec rake platform
else
    bundle exec rake common
fi