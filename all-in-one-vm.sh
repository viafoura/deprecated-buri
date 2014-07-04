#!/bin/bash

SCRIPT_PATH=$(readlink -f $0)
BURI_BASE=$(dirname ${SCRIPT_PATH})

${BURI_BASE}/bin/create-cassandra-keys.sh dev_vm

ansible-playbook ${BURI_BASE}/playbooks/all-in-one-live.yml -i ${BURI_BASE}/playbooks/dev_vm/inventory -e "machine_target=$1" -vvvv

