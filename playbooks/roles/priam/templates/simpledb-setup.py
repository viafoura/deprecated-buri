#!/usr/bin/python

# This is run by the BUILDER, never on the actual nodes.
# It will test to see if the domains exist, and only if they do not,
# Attempt to create and initialize.

import boto.sdb
from boto.sts import STSConnection
import sys
from pprint import pprint

appId ="{{ priam_cluster_name }}"

def put_record(domain, prop, val):
  print"Inserting into %s: %s -> %s" % (domain, prop, val)
  itemname ="%s.%s" % (appId, prop)
  sdb.put_attributes(domain, itemname, {"appId" : appId,"property" : prop,"value" : val})
  return

roleArn = '{{ priam_assume_role_arn|default('None') }}'

if roleArn == 'None':
    sdb = boto.sdb.connect_to_region("us-east-1")
else:
    sts = STSConnection()
    assumed = sts.assume_role(roleArn, 'sdb_script')
    sdb = boto.sdb.connect_to_region('us-east-1', aws_access_key_id=assumed.credentials.access_key, aws_secret_access_key=assumed.credentials.secret_key, security_token=assumed.credentials.session_token)

ii = sdb.lookup("InstanceIdentity", validate=True)
if ii is None:
  print"No InstanceIdentity, creating."
  ii = sdb.create_domain("InstanceIdentity")

pp = sdb.lookup("PriamProperties", validate=True)
if pp is None:
  print"No PriamProperties, creating."
  pp = sdb.create_domain("PriamProperties")

put_record("PriamProperties","priam.s3.bucket","{{ priam_s3_bucket }}")
put_record("PriamProperties","priam.s3.base_dir","{{ priam_s3_base_dir }}")
put_record("PriamProperties","priam.clustername","{{ priam_cluster_name }}")
put_record("PriamProperties","priam.data.location","{{ cassandra_data_location }}")
put_record("PriamProperties","priam.cache.location","{{ cassandra_cache_location }}")
put_record("PriamProperties","priam.commitlog.location","{{ cassandra_commitlog_location }}")
put_record("PriamProperties","priam.cass.home","{{ cassandra_home }}")
put_record("PriamProperties","priam.cass.startscript","{{ priam_cass_startscript }}")
put_record("PriamProperties","priam.cass.stopscript","{{ priam_cass_stopscript }}")
put_record("PriamProperties","priam.endpoint_snitch","{{ priam_endpoint_snitch }}")
put_record("PriamProperties","priam.upload.throttle","{{ priam_upload_throttle }}")
put_record("PriamProperties","priam.nativeTransport.enabled","{{ priam_native_transport_enabled }}")
put_record("PriamProperties","priam.internodeEncryption","{{ priam_internode_encryption }}")
{% if priam_multiregion_enable %}
put_record("PriamProperties","priam.multiregion.enable","{{ priam_multiregion_enable }}")
{% endif %}
{% if priam_zones_available !="" %}
put_record("PriamProperties","priam.zones.available","{{ priam_zones_available }}")
{% endif %}
{% if priam_acl_groupname !="" %}
put_record("PriamProperties","priam.acl.groupname","{{ priam_acl_groupname }}")
{% endif %}
{% if priam_vpc %}
put_record("PriamProperties","priam.vpc","{{ priam_vpc }}")
{% endif %}
put_record("PriamProperties","priam.backup.hour","{{ priam_backup_hour }}")
put_record("PriamProperties","priam.compaction.throughput","{{ priam_compaction_throughput }}")
# Not used in 2.1, but we'll set it for those on 2.0.x or less
put_record("PriamProperties","priam.memory.compaction.limit","{{ priam_compaction_limit }}")
# These are not tunable from Ansible, probably no reason to.
# Recommendations per http://docs.datastax.com/en/cassandra/2.1/cassandra/operations/ops_tune_jvm_c.html
# Direct memory is off-heap storage, ultimately setting XX:MaxDirectMemorySize
# c1.medium
put_record("PriamProperties","priam.heap.size.c1.medium","870M")
put_record("PriamProperties","priam.heap.newgen.size.c1.medium","435M")
put_record("PriamProperties","priam.direct.memory.size.c1.medium","460M")
# c1.xlarge
put_record("PriamProperties","priam.heap.size.c1.xlarge","1792M")
put_record("PriamProperties","priam.heap.newgen.size.c1.xlarge","896M")
put_record("PriamProperties","priam.direct.memory.size.c1.xlarge","3840M")
# c3.2xlarge
put_record("PriamProperties","priam.heap.size.c3.2xlarge","3840M")
put_record("PriamProperties","priam.heap.newgen.size.c3.2xlarge","1920M")
put_record("PriamProperties","priam.direct.memory.size.c3.2xlarge","9472M")
# c3.4xlarge
put_record("PriamProperties","priam.heap.size.c3.4xlarge","7680M")
put_record("PriamProperties","priam.heap.newgen.size.c3.4xlarge","3840M")
put_record("PriamProperties","priam.direct.memory.size.c3.4xlarge","20992M")
# c3.8xlarge
put_record("PriamProperties","priam.heap.size.c3.8xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.c3.8xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.c3.8xlarge","51200M")
# c3.large
put_record("PriamProperties","priam.heap.size.c3.large","960M")
put_record("PriamProperties","priam.heap.newgen.size.c3.large","480M")
put_record("PriamProperties","priam.direct.memory.size.c3.large","1968M")
# c3.xlarge
put_record("PriamProperties","priam.heap.size.c3.xlarge","1920M")
put_record("PriamProperties","priam.heap.newgen.size.c3.xlarge","960M")
put_record("PriamProperties","priam.direct.memory.size.c3.xlarge","4128M")
# cc2.8xlarge
put_record("PriamProperties","priam.heap.size.cc2.8xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.cc2.8xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.cc2.8xlarge","51712M")
# cg1.4xlarge
put_record("PriamProperties","priam.heap.size.cg1.4xlarge","5760M")
put_record("PriamProperties","priam.heap.newgen.size.cg1.4xlarge","2880M")
put_record("PriamProperties","priam.direct.memory.size.cg1.4xlarge","15232M")
# cr1.8xlarge
put_record("PriamProperties","priam.heap.size.cr1.8xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.cr1.8xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.cr1.8xlarge","239616M")
# g2.2xlarge
put_record("PriamProperties","priam.heap.size.g2.2xlarge","3840M")
put_record("PriamProperties","priam.heap.newgen.size.g2.2xlarge","1920M")
put_record("PriamProperties","priam.direct.memory.size.g2.2xlarge","9472M")
# hi1.4xlarge
put_record("PriamProperties","priam.heap.size.hi1.4xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.hi1.4xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.hi1.4xlarge","51712M")
# hs1.8xlarge
put_record("PriamProperties","priam.heap.size.hs1.8xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.hs1.8xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.hs1.8xlarge","109568M")
# i2.2xlarge
put_record("PriamProperties","priam.heap.size.i2.2xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.i2.2xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.i2.2xlarge","52224M")
# i2.4xlarge
put_record("PriamProperties","priam.heap.size.i2.4xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.i2.4xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.i2.4xlarge","114688M")
# i2.8xlarge
put_record("PriamProperties","priam.heap.size.i2.8xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.i2.8xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.i2.8xlarge","239616M")
# i2.xlarge
put_record("PriamProperties","priam.heap.size.i2.xlarge","7808M")
put_record("PriamProperties","priam.heap.newgen.size.i2.xlarge","3904M")
put_record("PriamProperties","priam.direct.memory.size.i2.xlarge","21376M")
# m1.large
put_record("PriamProperties","priam.heap.size.m1.large","1920M")
put_record("PriamProperties","priam.heap.newgen.size.m1.large","960M")
put_record("PriamProperties","priam.direct.memory.size.m1.large","4128M")
# m1.medium
put_record("PriamProperties","priam.heap.size.m1.medium","960M")
put_record("PriamProperties","priam.heap.newgen.size.m1.medium","480M")
put_record("PriamProperties","priam.direct.memory.size.m1.medium","1968M")
# m1.small
put_record("PriamProperties","priam.heap.size.m1.small","870M")
put_record("PriamProperties","priam.heap.newgen.size.m1.small","435M")
put_record("PriamProperties","priam.direct.memory.size.m1.small","460M")
# m1.xlarge
put_record("PriamProperties","priam.heap.size.m1.xlarge","3840M")
put_record("PriamProperties","priam.heap.newgen.size.m1.xlarge","1920M")
put_record("PriamProperties","priam.direct.memory.size.m1.xlarge","9472M")
# m2.2xlarge
put_record("PriamProperties","priam.heap.size.m2.2xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.m2.2xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.m2.2xlarge","24780M")
# m2.4xlarge
put_record("PriamProperties","priam.heap.size.m2.4xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.m2.4xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.m2.4xlarge","59801M")
# m2.xlarge
put_record("PriamProperties","priam.heap.size.m2.xlarge","4377M")
put_record("PriamProperties","priam.heap.newgen.size.m2.xlarge","2188M")
put_record("PriamProperties","priam.direct.memory.size.m2.xlarge","11085M")
# m3.2xlarge
put_record("PriamProperties","priam.heap.size.m3.2xlarge","7680M")
put_record("PriamProperties","priam.heap.newgen.size.m3.2xlarge","3840M")
put_record("PriamProperties","priam.direct.memory.size.m3.2xlarge","20992M")
# m3.large
put_record("PriamProperties","priam.heap.size.m3.large","1920M")
put_record("PriamProperties","priam.heap.newgen.size.m3.large","960M")
put_record("PriamProperties","priam.direct.memory.size.m3.large","4128M")
# m3.medium
put_record("PriamProperties","priam.heap.size.m3.medium","960M")
put_record("PriamProperties","priam.heap.newgen.size.m3.medium","480M")
put_record("PriamProperties","priam.direct.memory.size.m3.medium","1968M")
# m3.xlarge
put_record("PriamProperties","priam.heap.size.m3.xlarge","3840M")
put_record("PriamProperties","priam.heap.newgen.size.m3.xlarge","1920M")
put_record("PriamProperties","priam.direct.memory.size.m3.xlarge","9472M")
# r3.2xlarge
put_record("PriamProperties","priam.heap.size.r3.2xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.r3.2xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.r3.2xlarge","52224M")
# r3.4xlarge
put_record("PriamProperties","priam.heap.size.r3.4xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.r3.4xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.r3.4xlarge","114688M")
# r3.8xlarge
put_record("PriamProperties","priam.heap.size.r3.8xlarge","8192M")
put_record("PriamProperties","priam.heap.newgen.size.r3.8xlarge","4096M")
put_record("PriamProperties","priam.direct.memory.size.r3.8xlarge","239616M")
# r3.large
put_record("PriamProperties","priam.heap.size.r3.large","3840M")
put_record("PriamProperties","priam.heap.newgen.size.r3.large","1920M")
put_record("PriamProperties","priam.direct.memory.size.r3.large","9472M")
# r3.xlarge
put_record("PriamProperties","priam.heap.size.r3.xlarge","7808M")
put_record("PriamProperties","priam.heap.newgen.size.r3.xlarge","3904M")
put_record("PriamProperties","priam.direct.memory.size.r3.xlarge","21376M")
# t1.micro
put_record("PriamProperties","priam.heap.size.t1.micro","314M")
put_record("PriamProperties","priam.heap.newgen.size.t1.micro","157M")
put_record("PriamProperties","priam.direct.memory.size.t1.micro","44M")
# t2.medium
put_record("PriamProperties","priam.heap.size.t2.medium","1024M")
put_record("PriamProperties","priam.heap.newgen.size.t2.medium","512M")
put_record("PriamProperties","priam.direct.memory.size.t2.medium","2112M")
# t2.micro
put_record("PriamProperties","priam.heap.size.t2.micro","512M")
put_record("PriamProperties","priam.heap.newgen.size.t2.micro","256M")
put_record("PriamProperties","priam.direct.memory.size.t2.micro","192M")
# t2.small
put_record("PriamProperties","priam.heap.size.t2.small","512M")
put_record("PriamProperties","priam.heap.newgen.size.t2.small","256M")
put_record("PriamProperties","priam.direct.memory.size.t2.small","960M")
