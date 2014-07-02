#!/bin/bash

ENVIRO=$1
if [ "x$ENVIRO" == "x" ]; then
  echo "Must supply environment name"
  exit 1
fi
BASE="playbooks/$ENVIRO/local"
if [ ! -d "${BASE}" ]; then
  echo "Invalid environment directory: $ENVIRO"
  exit 1
fi


openssl genrsa -out ${BASE}/bundle_pk.pem 2048
openssl req -new -x509 -sha1 -days 3750 -key ${BASE}/bundle_pk.pem -out ${BASE}/bundle_cert.pem -batch

