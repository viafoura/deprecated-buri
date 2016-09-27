#!/bin/bash 


#cassandra-env.sh file
file="/opt/cassandra/conf/cassandra-env.sh"

sed -i -e 's/^\(\s*LOCAL_JMX=\)yes/\1no/'  $file
sed -i -e 's/^\(\s*JVM_OPTS.*authenticate=\)true/\1false/' $file
sed -i -e 's/^\(\s*JVM_OPTS.*etc.*password\)/#\1/' $file
sed -i -e 's/^\(JVM_OPTS.*MX4J.*\)/#\1/' $file

#cassandra file
file="/opt/cassandra/bin/cassandra"
sed -i -e ' /cassandra-env.sh/,+2 s/^/#/' $file


