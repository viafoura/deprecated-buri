#!/usr/bin/python

import sys
import boto.sdb

if len(sys.argv) != 3:
  print "must supply cluster and hostname to remove"
  sys.exit(1)

cluster = sys.argv[1]
hostname = sys.argv[2]
print "Removing hostname %s from cluster %s:" % (hostname, cluster)

sdb = boto.sdb.connect_to_region("us-east-1")
ii = sdb.lookup("InstanceIdentity", validate=True)

result = sdb.select('InstanceIdentity', 'select * from InstanceIdentity where (appId="%s" or appId="%s-dead") and hostname="%s"' % (cluster, cluster, hostname))
for l in result:
  print "Removing Item %s: " % l.name
  ii.delete_item(l)