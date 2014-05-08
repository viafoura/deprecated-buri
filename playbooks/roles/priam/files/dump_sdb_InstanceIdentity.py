#!/usr/bin/python

import boto
import sys
from pprint import pprint

sdb = boto.connect_sdb()
result = sdb.select('InstanceIdentity', 'select * from InstanceIdentity')

for l in result:
  sys.stdout.write("Item %s: " % l.name)
  pprint(l)

