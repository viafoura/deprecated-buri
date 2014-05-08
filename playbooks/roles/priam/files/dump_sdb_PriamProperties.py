#!/usr/bin/python

import boto
import sys
from pprint import pprint

sdb = boto.connect_sdb()
result = sdb.select('PriamProperties', 'select * from PriamProperties')

for l in result:
  sys.stdout.write("Item %s: " % l.name)
  pprint(l)

