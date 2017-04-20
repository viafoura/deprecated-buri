#!/bin/bash

# Discover true path of where buri is running from
pushd $(dirname $0) > /dev/null 2>&1
SCRIPT_PATH=$PWD/$(basename $0)
popd > /dev/null 2>&1
BURI_BASE=$(dirname ${SCRIPT_PATH})

# FIXME: for consistency, this should install oracle java

# Update and install Ubuntu packages
sudo perl -pi -e 's/^# *(deb .*multiverse)$/$1/' /etc/apt/sources.list
sudo perl -pi -e 's/^# *(deb .*backports)$/$1/' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo -E apt-get upgrade -y
sudo -E apt-get install --no-install-recommends -y \
 coreutils                \
 ec2-ami-tools            \
 python                   \
 python-dev               \
 python-pip               \
 python-jinja2            \
 libapt-pkg4.12           \
 make                     \
 qemu-utils               \
 git-core                 \
 build-essential          \
 pigz                     \
 libssl-dev               \
 libffi-dev               \
openssl

if [[ $(lsb_release -rs) -lt 16 ]]; then 
  sudo -E apt-get install --no-install-recommends -y python-support
fi

sudo pip install boto
sudo pip install awscli
sudo pip install ansible=2.2.2

