#!/usr/bin/python
# -*- coding: utf-8 -*-


import urllib2 
import json
import boto.ec2.cloudwatch


hst='http://169.254.169.254/latest/meta-data/local-ipv4/'

res = urllib2.urlopen(hst)
host = res.read()

url="http://{}:8080/Priam/REST/v1/cassadmin/ring/system".format(host)

response = urllib2.urlopen(url)
data = json.load(response)

val = 0

for i in data:
    if i['status'] == "Down":
        val += 1

conn = boto.ec2.cloudwatch.connect_to_region('us-east-1')
conn.put_metric_data(namespace='Cassandra', name='Down', value=val, dimensions=[{'Cluster': '{{ priam_cluster_name }}' }])

