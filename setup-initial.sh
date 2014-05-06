#!/bin/bash

# Update and install Ubuntu packages
export DEBIAN_FRONTEND=noninteractive
sudo perl -pi -e 's/^# *(deb .*multiverse)$/$1/' /etc/apt/sources.list
sudo perl -pi -e 's/^# *(deb .*backports)$/$1/' /etc/apt/sources.list
sudo add-apt-repository -y ppa:jhohertz/aws-ppa
sudo apt-get update
sudo -E apt-get upgrade -y
sudo -E apt-get install --no-install-recommends -y \
 coreutils                \
 ec2-ami-tools            \
 ec2-api-tools            \
 python                   \
 python-support           \
 python-pip               \
 python-crypto            \
 python-jinja2            \
 libapt-pkg4.12           \
 make                     \
 qemu-utils               \
 git-core                 \
 openssl                  \
 ansible

sudo pip install boto
sudo pip install awscli


