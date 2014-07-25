#!/bin/bash

# Discover true path of where buri is running from
pushd $(dirname $0) > /dev/null 2>&1
SCRIPT_PATH=$PWD/$(basename $0)
popd > /dev/null 2>&1
SCRIPT_DIR=$(dirname ${SCRIPT_PATH})
BURI_BASE=$(dirname ${SCRIPT_DIR})

ENVIRO=$1
if [ "x$ENVIRO" == "x" ]; then
  echo "Must supply environment name"
  exit 1
fi
BASE="${BURI_BASE}/playbooks/$ENVIRO/local"
if [ ! -d "${BASE}" ]; then
  echo "Invalid environment directory for $ENVIRO: ${BASE}"
  exit 1
fi

echo -n "Checking for bundle_pk.pem: "
if [ ! -f "${BASE}/bundle_pk.pem" ]; then
  #rm ${BASE}/cassandra_truststore
  #1 Generate key and store
  echo Creating new bundle_pk.pem
  openssl genrsa -out ${BASE}/bundle_pk.pem 2048
else
  echo bundle_pk.pem found
fi

echo -n "Checking for bundle_cert.pem: "
if [ ! -f "${BASE}/bundle_cert.pem" ]; then
  #rm ${BASE}/cassandra_truststore
  #1 Generate key and store
  echo Creating new bundle_cert.pem
  openssl req -new -x509 -sha1 -days 3750 -key ${BASE}/bundle_pk.pem -out ${BASE}/bundle_cert.pem -batch
else
  echo bundle_cert.pem found
fi


