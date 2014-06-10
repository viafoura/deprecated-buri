#!/bin/bash

ansible-playbook playbooks/run-role-live.yml -i inventory/local -e "machine_target=$1 ami_role=$2" -vvvv

