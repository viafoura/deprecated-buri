#!/usr/bin/python

import os
import re
import random

#device_letters = 'qrstuvwx'     # Not in Aminator's default range
device_letters = 'abc'     # Not in Aminator's default range
device_numbers = xrange(1, 16)

def get_device_node(mode="flat"):
    exists = True
    while 1:
        dev = get_random_device_node(mode)
        if mode == "flat":
            if not os.path.exists(dev) and not os.path.exists(re.sub(r'[0-9]+$', '', dev)):
                return dev
        else:
            if not os.path.exists(dev):
                return dev

def get_random_device_node(mode="flat"):
    ret = "/dev/sd"
    ret += random.choice(device_letters)
    if mode == "flat":
      ret += str(random.choice(device_numbers))
    return ret

mode = "fldat"
print get_device_node(mode)

