#!/bin/bash

ansible-playbook playbooks/create-foundation-ubuntu.yml -i inventory/local -e "ami_role=foundation" -vvvv

