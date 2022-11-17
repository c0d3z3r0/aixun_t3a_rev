#!/usr/bin/env python3

import shutil
import sys


def revbits(data, bits):
  x = 0
  for i in range(bits):
    if data & (1 << i):
      x |= (1 << (bits - 1 - i))
  return x

def calc_crc(data):
  dst = 0xffff
  for d in data:
    dst ^= (revbits(d, 8) << 8)
    for j in range(8):
      if dst & 0x8000:
        dst = (dst << 1) & 0xffff
        dst ^= 0x8005
      else:
        dst = (dst << 1) & 0xffff
  dst = revbits(dst, 16)
  return dst.to_bytes(2, 'big')


if __name__ == '__main__':
  start = 0
  size = 0
  signature_off = 0
  crc = 0
  data = b''

  f = open(sys.argv[1], 'rb')
  if f.read(4) == b'JCID':
    print("Detected update image")
    start = 0x100

  else:
    f.seek(0x3f800)
    if f.read(4) == b'JCID':
      print("Detected flash image")
      start = 0x10000
      signature_off = 0x3f800

    else:
      print("Unknown image. Abort.")
      sys.exit(1)

  f.seek(signature_off + 0x60)
  size = int.from_bytes(f.read(4), 'big')
  crc  = f.read(2)

  f.seek(start)
  data = f.read(size)

  ccrc = calc_crc(data)

  if crc == ccrc:
    print(f"CRC correct: {ccrc.hex()}")
    sys.exit(0)

  else:
    print(f"CRC mismatch: {crc.hex()} vs. calculated {ccrc.hex()}")
    newfile = f"{sys.argv[1]}.patched"
    shutil.copyfile(sys.argv[1], newfile)
    n = open(newfile, 'r+b')
    n.seek(signature_off + 0x64)
    n.write(ccrc)
    n.close()
    print(f"Patched file saved to {newfile}")
