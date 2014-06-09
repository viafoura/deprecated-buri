#!/bin/bash

ansible-playbook playbooks/run-role-live.yml -i inventory/devvm -e "ami_role=$1" -vvvv

