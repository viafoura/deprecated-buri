#!/bin/bash

# Discover true path of where buri is running from
pushd $(dirname $0) > /dev/null 2>&1
SCRIPT_PATH=$PWD/$(basename $0)
popd > /dev/null 2>&1
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

ansible-playbook ${BURI_BASE}/playbooks/setup-build-host.yml -i ${BURI_BASE}/playbooks/${ENVIRO}/inventory -e "machine_target=$2" -vvvv

