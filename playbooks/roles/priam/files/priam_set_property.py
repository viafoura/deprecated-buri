#!/usr/bin/python

import sys
import boto.sdb

if len(sys.argv) != 4:
  print "must supply cluster name, key, and value to set"
  sys.exit(1)

cluster = sys.argv[1]
key = "priam.%s" % sys.argv[2]
val = sys.argv[3]

sdb = boto.sdb.connect_to_region("us-east-1")
pp = sdb.lookup("PriamProperties", validate=True)
itemname = "%s.%s" % (cluster, key)
if val != "DELETE":
  sdb.put_attributes(pp, itemname, {"appId" : cluster, "property" : key, "value" : val})
else:
  sdb.delete_attributes(pp, itemname)

