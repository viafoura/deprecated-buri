#!/usr/bin/python

import boto
sdb = boto.connect_sdb()

ii = sdb.lookup("InstanceIdentity", validate=True)
if ii is not None:
  print "Dropping InstanceIdentity."
  sdb.delete_domain('InstanceIdentity')

pp = sdb.lookup("PriamProperties", validate=True)
if pp is not None:
  print "Dropping PriamProperties."
  sdb.delete_domain('PriamProperties')


