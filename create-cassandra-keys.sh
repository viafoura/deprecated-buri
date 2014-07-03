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

ALIAS="cassandra"
rm ${BASE}/cassandra_truststore

#1 Generate key and store
keytool -genkey -v -keyalg RSA -keysize 1024 -alias ${ALIAS} -keystore ${BASE}/cassandra_keystore -storepass "cassandra" -dname 'CN=cassandra' -keypass "cassandra" -validity 3650

#2 Extract public certificate
keytool -export -v -alias ${ALIAS} -file ${BASE}/cassandra_cert -keystore ${BASE}/cassandra_keystore -storepass "cassandra"
   
#3 Add public certificate to global keystore
keytool -import -v -trustcacerts -alias ${ALIAS} -file ${BASE}/cassandra_cert -keystore ${BASE}/cassandra_truststore -storepass 'cassandra' -noprompt

