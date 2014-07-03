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

ansible-playbook playbooks/resnap-via-playbook.yml -i playbooks/${ENVIRO}/inventory -e "ami_parent=$2 ami_role=$3" -vvvv

