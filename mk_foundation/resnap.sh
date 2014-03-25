#!/bin/bash

ansible-playbook playbooks/resnap-via-playbook.yml -i inventory/local -e "ami_parent=$1 ami_role=$2" -vvvv

