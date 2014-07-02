#!/bin/bash

#ENVIRO=$1
#if [ "x$ENVIRO" == "x" ]; then
#  echo "Must supply environment name"
#  exit 1
#fi
#BASE="playbooks/$ENVIRO/local"
#if [ ! -d "${BASE}" ]; then
#  echo "Invalid environment directory: $ENVIRO"
#  exit 1
#fi

# Doesnt matter much what we use here
ENVIRO=test

ansible-playbook playbooks/cleanup-failure.yml -i playbooks/${ENVIRO}/inventory -vvvv

