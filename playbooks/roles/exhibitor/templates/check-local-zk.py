#!/usr/bin/env python
# vim: ft=python:

import json
import sys
import time
import urllib2
import commands
from datetime import datetime, timedelta

def get_stat():
    # FIXME: use boto
    myhostname = commands.getoutput("ec2metadata --public-hostname").rstrip()
    url = 'http://localhost:{{ exhibitor_instance_port }}/exhibitor/v1/cluster/state/' + myhostname

    f = urllib2.urlopen(url, timeout=1)

    if f.getcode() != 200:
        raise Exception("Non 200 response from exhibitor")

    return json.loads(f.read())['response']

if __name__ == '__main__':
    end = datetime.now() + timedelta(minutes=5)
    while datetime.now() < end:
        try:
            if get_stat()['description'] == 'serving':
                sys.exit(0)
        except Exception, e:
            print e
        time.sleep(1)
    sys.exit(1)
