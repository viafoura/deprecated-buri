#!/bin/bash

ALIAS="priam"
rm playbooks/local/priam_truststore

#1 Generate key and store
keytool -genkey -v -keyalg RSA -keysize 1024 -alias ${ALIAS} -keystore playbooks/local/priam_keystore -storepass "cassandra" -dname 'CN=priam' -keypass "cassandra" -validity 3650

#2 Extract public certificate
keytool -export -v -alias ${ALIAS} -file playbooks/local/priam_cert -keystore playbooks/local/priam_keystore -storepass "cassandra"
   
#3 Add public certificate to global keystore
keytool -import -v -trustcacerts -alias ${ALIAS} -file playbooks/local/priam_cert -keystore playbooks/local/priam_truststore -storepass 'cassandra' -noprompt

