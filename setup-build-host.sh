#!/bin/bash

ENVIRO=$1
if [ "x$ENVIRO" == "x" ]; then
  echo "Must supply environment name"
  exit 1
fi
BASE="playbooks/$ENVIRO/local"
if [ ! -d "${BASE}" ]; then
  echo "Invalid environment directory: $ENVIRO"
  exit 1
fi

ansible-playbook playbooks/setup-build-host.yml -i playbooks/${ENVIRO}/inventory -vvvv

