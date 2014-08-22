#!/usr/bin/python

import random

device_letters = 'qrstuvwx'
device_numbers = xrange(1, 16)
letter = random.choice(device_letters)
number = random.choice(device_numbers)
device_top = "/dev/xvd" + letter
device = "{0}{1}".format(device_top, number)

print device

