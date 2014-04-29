#!/bin/bash

openssl genrsa -out playbooks/local/bundle_pk.pem 2048
openssl req -new -x509 -sha1 -days 3750 -key playbooks/local/bundle_pk.pem -out playbooks/local/bundle_cert.pem -batch

