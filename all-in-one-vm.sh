#!/bin/bash

ansible-playbook playbooks/all-in-one-live.yml -i playbooks/dev_vm/inventory -e "machine_target=$1" -vvvv

