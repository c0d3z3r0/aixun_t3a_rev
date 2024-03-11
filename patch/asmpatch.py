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
if f.read(4) == b'JCID':
  print("Detected update image")
  flashbase += 0x10000 # bootloader
  flashbase -= 0x100   # update header size

else:
  f.seek(0x3f800)
  if f.read(4) == b'JCID':
    print("Detected flash image")

  else:
    print("Unknown image. Abort.")
    sys.exit(1)

for p in patches:
  off, patch = p.split('\t')[0:2]
  off = int(off.strip().rstrip(':'), 16) - flashbase
  patch = b''.join(bytes.fromhex(v)[::-1] for v in patch.split(" "))

  f.seek(off)
  f.write(patch)

f.close()
