#!/usr/bin/python

import boto
import sys
from pprint import pprint

appId = "cassandra_sandbox_example"

def put_record(domain, prop, val):
  print "Inserting into %s: %s -> %s" % domain,prop,val
  itemname = "%s.%s" % appId, prop
  sdb.put_attributes(domain, itemname, {"appId" => appId, "property" => prop, "value" => val})
  return

sdb = boto.connect_sdb()

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
{% if priam_multiregion_enable %}
  put_record("PriamProperties", "priam.multiregion.enable", "{{ priam_multiregion_enable }}")
{% endif %}
{% if priam_zones_available != "" %}
  put_record("PriamProperties", "priam.zones.available", "{{ priam_zones_available }}")
{% endif %}
