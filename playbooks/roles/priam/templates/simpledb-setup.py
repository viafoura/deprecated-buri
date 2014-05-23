#!/usr/bin/python

# This is run by the BUILDER, never on the actual nodes.
# It will test to see if the domains exist, and only if they do not,
# Attempt to create and initialize.

import boto.sdb
import sys
from pprint import pprint

appId = "{{ priam_clustername }}"

def put_record(domain, prop, val):
  print "Inserting into %s: %s -> %s" % (domain, prop, val)
  itemname = "%s.%s" % (appId, prop)
  sdb.put_attributes(domain, itemname, {"appId" : appId, "property" : prop, "value" : val})
  return

sdb = boto.sdb.connect_to_region("us-east-1")

ii = sdb.lookup("InstanceIdentity", validate=True)
if ii is None:
  print "No InstanceIdentity, creating."
  ii = sdb.create_domain("InstanceIdentity")

pp = sdb.lookup("PriamProperties", validate=True)
if pp is None:
  print "No PriamProperties, creating."
  pp = sdb.create_domain("PriamProperties")
  put_record("PriamProperties", "priam.s3.bucket", "{{ priam_s3_bucket }}")
  put_record("PriamProperties", "priam.s3.base_dir", "{{ priam_s3_base_dir }}")
  put_record("PriamProperties", "priam.clustername", "{{ priam_clustername }}")
  put_record("PriamProperties", "priam.data.location", "{{ cassandra_data_location }}")
  put_record("PriamProperties", "priam.cache.location", "{{ cassandra_cache_location }}")
  put_record("PriamProperties", "priam.commitlog.location", "{{ cassandra_commitlog_location }}")
  put_record("PriamProperties", "priam.cass.home", "{{ cassandra_home }}")
  put_record("PriamProperties", "priam.cass.startscript", "{{ priam_cass_startscript }}")
  put_record("PriamProperties", "priam.cass.stopscript", "{{ priam_cass_stopscript }}")
  put_record("PriamProperties", "priam.endpoint_snitch", "{{ priam_endpoint_snitch }}")
  put_record("PriamProperties", "priam.upload.throttle", "{{ priam_upload_throttle }}")
  put_record("PriamProperties", "priam.internodeEncryption", "{{ priam_internode_encryption }}")
{% if priam_multiregion_enable %}
  put_record("PriamProperties", "priam.multiregion.enable", "{{ priam_multiregion_enable }}")
{% endif %}
{% if priam_zones_available != "" %}
  put_record("PriamProperties", "priam.zones.available", "{{ priam_zones_available }}")
{% endif %}
{% if priam_acl_groupname != "" %}
  put_record("PriamProperties", "priam.acl.groupname", "{{ priam_acl_groupname }}")
{% endif %}
{% if priam_vpc %}
  put_record("PriamProperties", "priam.vpc", "{{ priam_vpc }}")
{% endif %}
  put_record("PriamProperties", "priam.backup.hour", "{{ priam_backup_hour }}")
  put_record("PriamProperties", "priam.compaction.throughput", "{{ priam_compaction_throughput }}")
  put_record("PriamProperties", "priam.memory.compaction.limit", "{{ priam_compaction_limit }}")
  # These are not tunable from Ansible, probably no reason to.
  # i2.xlarge
  put_record("PriamProperties", "priam.heap.size.i2.xlarge", "8G")
  put_record("PriamProperties", "priam.heap.newgen.size.i2.xlarge", "2G")
  put_record("PriamProperties", "priam.direct.memory.size.i2.xlarge", "20G")
  # i2.2xlarge
  put_record("PriamProperties", "priam.heap.size.i2.2xlarge", "8G")
  put_record("PriamProperties", "priam.heap.newgen.size.i2.2xlarge", "2G")
  put_record("PriamProperties", "priam.direct.memory.size.i2.2xlarge", "50G")
  # i2.4xlarge
  put_record("PriamProperties", "priam.heap.size.i2.4xlarge", "8G")
  put_record("PriamProperties", "priam.heap.newgen.size.i2.4xlarge", "2G")
  put_record("PriamProperties", "priam.direct.memory.size.i2.4xlarge", "112G")
  # i2.8xlarge
  put_record("PriamProperties", "priam.heap.size.i2.8xlarge", "8G")
  put_record("PriamProperties", "priam.heap.newgen.size.i2.8xlarge", "2G")
  put_record("PriamProperties", "priam.direct.memory.size.i2.8xlarge", "234G")
  # m1.small
  put_record("PriamProperties", "priam.heap.size.m1.small", "512M")
  put_record("PriamProperties", "priam.heap.newgen.size.m1.small", "128M")
  put_record("PriamProperties", "priam.direct.memory.size.m1.small", "1G")
  # m1.large
  put_record("PriamProperties", "priam.heap.size.m1.large", "2G")
  put_record("PriamProperties", "priam.heap.newgen.size.m1.large", "512M")
  put_record("PriamProperties", "priam.direct.memory.size.m1.large", "4G")
  # m1.xlarge
  put_record("PriamProperties", "priam.heap.size.m1.xlarge", "4G")
  put_record("PriamProperties", "priam.heap.newgen.size.m1.xlarge", "1G")
  put_record("PriamProperties", "priam.direct.memory.size.m1.xlarge", "10G")

