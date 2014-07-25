#!/bin/bash

# Discover true path of where buri is running from
pushd $(dirname $0) > /dev/null 2>&1
SCRIPT_PATH=$PWD/$(basename $0)
popd > /dev/null 2>&1
BURI_BASE=$(dirname ${SCRIPT_PATH})

${BURI_BASE}/bin/create-cassandra-keys.sh dev_vm

ansible-playbook ${BURI_BASE}/playbooks/all-in-one-live.yml -i ${BURI_BASE}/playbooks/dev_vm/inventory -e "machine_target=$1" -vvvv

