#!/bin/bash

ansible-playbook playbooks/all-in-one-live.yml -i inventory/local -e "machine_target=$1" -vvvv

