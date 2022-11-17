#!/usr/bin/env python3

import re
import shutil
import sys

flashbase = 0x8000000
patt = re.compile(r"^ [a-f0-9]+:")

p = open(sys.argv[1], 'r')
patches = p.read().splitlines()
patches = filter(lambda l: patt.match(l), patches)
p.close()

f = open(sys.argv[2], 'r+b')
for p in patches:
  off, patch = p.split('\t')[0:2]
  off = int(off.strip().rstrip(':'), 16) - flashbase
  patch = b''.join(bytes.fromhex(v)[::-1] for v in patch.split(" "))

  f.seek(off)
  f.write(patch)

f.close()
