#!/usr/bin/python

import boto.sdb
sdb = boto.sdb.connect_to_region("us-east-1")

ii = sdb.lookup("InstanceIdentity", validate=True)
if ii is not None:
  print "Dropping InstanceIdentity."
  sdb.delete_domain('InstanceIdentity')
  ii = sdb.create_domain("InstanceIdentity")

