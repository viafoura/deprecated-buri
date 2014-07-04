#!/bin/bash

SCRIPT_PATH=$(readlink -f $0)
BURI_BASE=$(dirname ${SCRIPT_PATH})


ENVIRO=$1
if [ "x$ENVIRO" == "x" ]; then
  echo "Must supply environment name"
  exit 1
fi
BASE="${BURI_BASE}/playbooks/$ENVIRO/local"
if [ ! -d "${BASE}" ]; then
  echo "Invalid environment directory for $ENVIRO: ${BASE}"
  exit 1
fi

ansible-playbook ${BURI_BASE}/playbooks/create-foundation-ubuntu.yml -i ${BURI_BASE}/playbooks/${ENVIRO}/inventory -e "ami_role=foundation" -vvvv

