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

ALIAS="cassandra"

echo -n "Checking for cassandra_keystore: "
if [ ! -f "${BASE}/cassandra_keystore" ]; then
  #rm ${BASE}/cassandra_truststore
  #1 Generate key and store
  echo Creating new cassandra_keystore
  keytool -genkey -v -keyalg RSA -keysize 1024 -alias ${ALIAS} -keystore ${BASE}/cassandra_keystore -storepass "cassandra" -dname 'CN=cassandra' -keypass "cassandra" -validity 3650
else
  echo cassandra_keystore found
fi

echo -n "Checking for cassandra_cert: "
if [ ! -f "${BASE}/cassandra_cert" ]; then
  #rm ${BASE}/cassandra_truststore
  echo Creating new cassandra_cert
  #2 Extract public certificate
  keytool -export -v -alias ${ALIAS} -file ${BASE}/cassandra_cert -keystore ${BASE}/cassandra_keystore -storepass "cassandra"
else
  echo cassandra_cert found
fi

echo -n "Checking for cassandra_truststore: "
if [ ! -f "${BASE}/cassandra_truststore" ]; then
  #rm ${BASE}/cassandra_truststore
  echo Creating new cassandra_truststore
  #3 Add public certificate to global keystore
  keytool -import -v -trustcacerts -alias ${ALIAS} -file ${BASE}/cassandra_cert -keystore ${BASE}/cassandra_truststore -storepass 'cassandra' -noprompt
else
  echo cassandra_truststore found
fi


   

