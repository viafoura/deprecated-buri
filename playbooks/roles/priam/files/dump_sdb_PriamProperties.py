#!/usr/bin/python

import boto.sdb
import sys
from pprint import pprint

sdb = boto.sdb.connect_to_region("us-east-1")
result = sdb.select('PriamProperties', 'select * from PriamProperties')

for l in result:
  sys.stdout.write("Item %s: " % l.name)
  pprint(l)

