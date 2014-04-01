#!/bin/bash

ansible-playbook playbooks/cleanup-failure.yml -i inventory/local -vvvv

