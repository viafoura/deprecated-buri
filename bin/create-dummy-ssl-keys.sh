#!/bin/bash

SCRIPT_PATH=$(readlink -f $0)
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
KEYNAME=$2
if [ "x$KEYNAME" == "x" ]; then
  echo "Must supply key name"
  exit 1
fi


ALIAS="cassandra"

echo -n "Checking for ${KEYNAME}_server.key: "
if [ ! -f "${BASE}/${KEYNAME}_server.key" ]; then
  echo Creating new ${KEYNAME}_server.key
  openssl genrsa -des3 -out ${BASE}/${KEYNAME}_server.key 1024
  #cp ${BASE}/${KEYNAME}_server.key ${BASE}/${KEYNAME}_server.key.org
else
  echo ${KEYNAME}_server.key found
fi

echo -n "Checking for ${KEYNAME}_server.csr: "
if [ ! -f "${BASE}/${KEYNAME}_server.csr" ]; then
  echo Creating new ${KEYNAME}_server.csr
  openssl req -new -key ${BASE}/${KEYNAME}_server.key -out ${BASE}/${KEYNAME}_server.csr
else
  echo ${KEYNAME}_server.csr found
fi

# Not sure, strips the password maybe?
echo -n "Checking for ${KEYNAME}_server.key2: "
if [ ! -f "${BASE}/${KEYNAME}_server.key2" ]; then
  echo Creating new ${KEYNAME}_server.key2
  openssl rsa -in ${BASE}/${KEYNAME}_server.key -out ${BASE}/${KEYNAME}_server.key2
else
  echo ${KEYNAME}_server.key2 found
fi

echo -n "Checking for ${KEYNAME}_server.crt: "
if [ ! -f "${BASE}/${KEYNAME}_server.crt" ]; then
  echo Creating new ${KEYNAME}_server.crt
  openssl x509 -req -days 365 -in ${BASE}/${KEYNAME}_server.csr -signkey ${BASE}/${KEYNAME}_server.key2 -out ${BASE}/${KEYNAME}_server.crt
else
  echo ${KEYNAME}_server.crt found
fi

