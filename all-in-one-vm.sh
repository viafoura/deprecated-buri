#!/bin/bash

# Discover true path of where buri is running from
pushd $(dirname $0) > /dev/null 2>&1
SCRIPT_PATH=$PWD/$(basename $0)
popd > /dev/null 2>&1
BURI_BASE=$(dirname ${SCRIPT_PATH})

ENVIRO=dev_vm

${BURI_BASE}/buri keys_cassandra

ansible-playbook ${BURI_BASE}/playbooks/run-role-live.yml -i ${BURI_BASE}/playbooks/${ENVIRO}/inventory -e "machine_target=$1 ami_role='all_in_one'" -vv

