#!/usr/bin/env python

# Decompression for Keil compressed RAM init data
#
# Modified to run without Ghidra
#
# Original work: https://github.com/dojoe/ghidra-scripts/blob/master/keil-decompress.py
#
# The Keil ARM toolchain stores the initialization data for .rwdata in a
# compressed block at the end of the flash binary. For static analysis
# it's helpful to unpack that data and load it into the disassembler.
#
# This script is meant to be used in cases where the all-inclusive
# automation of keil-ram-init.py doesn't work right and you need to
# reverse the RAM initialization by hand. It will take care purely
# of the decompression and leave everything else up to you.
#
# Usage:
# ======
#
# 1. Find the block of compressed init data; you need to identify both the
#    start and end location precisely. You also need the uncompressed size.
#    Read below about how to find these.
#
# 2. Select the entirety of the compressed data in the Byte viewer and run
#    this script. Enter the uncompressed size in the input popup.
#
# 3. The script will try all known decompression algorithms on the compressed
#    data and pick the one that yields the expected uncompressed size.
#    It will copy the uncompressed data into the clipboard as a hex string.
#
# 4. Paste the uncompressed data at the right location in the Bytes view.
#    (You need to enable editing by clicking the pencil icon in the top right
#    corner of the Bytes view, and if there are already any instructions or
#    data fields in the area you're trying to paste over nothing will happen -
#    in that case select the entire target area and clear everything by hitting
#    C first.)
#
# How to find the compressed init data:
# =====================================
#
# 1. Find the "__scatterload" function. This should be very easy if you have
#    your reset vector right - it's one of the first functions in the program
#    flow after the reset vector, and it's going through a table of parameters
#    and function pointers, calling each in succession.
#
#    So far I know of two types of these, one starts like so:
#
#      ldr r4, [pointer close to the end of the flash image]
#      ldr r5, #1
#      ldr r6, [pointer to N * 0x10 bytes behind the first]
#      b   <into a loop>
#
#    And the other type starts like so:
#
#      adr r0, [first of two dwords at the end of the function]
#      ldmia r0!, { r4, r5 }
#
# 2. The two pointers loaded above mark the start and the end of the
#    scatterload table. That table has N (usually two) entries of four dwords
#    each. Those four dwords are, in order:
#     - location of control data
#     - location of target RAM area
#     - length of target RAM area in bytes
#     - function to call
#    One entry usually points to a "clear memory" function (will be easy to
#    see in the decompiler), so you can zero-init the target RAM area.
#    The other entry will use compression of some sort.
#
# 3. The first dword in the unpack entry points to the beginning of the packed
#    data, and the unpacked size equals the length of the target area.
#
# 4. The tricky part is finding the end of the packed data. Sometimes the (unused)
#    first dword of the "clear memory" entry points to the first byte after the
#    packed data but I have seen targets where that's not the case. In that case
#    you'll have to guess and try a few times. Some hints:
#     - Most of the time the packed data is at the end of the image, or
#       immediately followed by FF padding bytes.
#     - The packed data usually ends with a 00 byte.
#
# Compression support:
# ====================
#
# Keil supports several compression algorithms; since there's no clear
# indication of which algorithm is used in a binary, the script simply
# tries them all and picks the one that decompresses cleanly.
#
# Currently supported algos:
#   No compression (__scatterload_copy)
#   Simple RLE (__decompress0)
#   RLE with LZ77 on small repeats (__decompress1)
#   Complex LZ77 (__decompress2)
#
#
# Copyright 2021 Joachim Fenkes <github@dojoe.net>
# License: GPLv3
# https://github.com/dojoe/ghidra-scripts/blob/master/LICENSE
#
# @author Joachim Fenkes <github@dojoe.net>
# @category ARM
# @keybinding
# @menupath
# @toolbar

from __future__ import print_function
from array import array
from binascii import hexlify
import readline
import tempfile
import sys
import binascii

def unpack_rle(packed, unpacked):
    """
    Decompress data compressed by the Keil RLE (__decompress0) algorithm
    """
    ctrl = packed.pop(0)
    literal_len = ((ctrl & 0xF) or packed.pop(0)) - 1
    zero_len = ((ctrl >> 4) or packed.pop(0)) - 1

    # copy literals, append zeros
    unpacked.extend(packed[:literal_len] + ([0] * zero_len))
    del packed[:literal_len]


def unpack_rlz77(packed, unpacked):
    """
    Decompress data compressed by the Keil RLE/LZ77 mixed (__decompress1) algorithm
    """
    ctrl = packed.pop(0)
    literal_len = ((ctrl & 7) or packed.pop(0)) - 1
    backref_len = (ctrl >> 4) or packed.pop(0)

    # copy literals
    unpacked.extend(packed[:literal_len])
    del packed[:literal_len]

    # process backrefs or zeros
    if ctrl & 8:
        offset = packed.pop(0)
        for _ in range(backref_len + 2):
            unpacked.append(unpacked[-offset])
    else:
        unpacked.extend([0] * backref_len)


def unpack_lz77(packed, unpacked):
    """
    Decompress data compressed by the Keil LZ77 (__decompress2) algorithm
    """
    ctrl = packed.pop(0)
    literal_len = ((ctrl & 3) or packed.pop(0)) - 1
    backref_len = ((ctrl >> 4) or packed.pop(0)) + 2

    # copy literals
    unpacked.extend(packed[:literal_len])
    del packed[:literal_len]

    # process backrefs
    if backref_len:
        offset_lo = packed.pop(0)
        offset_hi = (ctrl >> 2) & 3
        if offset_hi == 3:
            offset_hi = packed.pop(0)
        offset = offset_hi * 0x100 + offset_lo

        for _ in range(backref_len):
            unpacked.append(unpacked[-offset])


unpack_cores = [
    (unpack_rle,   "__decompress0", "RLE"),
    (unpack_rlz77, "__decompress1", "RLE/LZ77 mixed"),
    (unpack_lz77,  "__decompress2", "LZ77")
]


def unpack(packed, unpacked_size, core):
    """
    Decompress Keil compressed data using the specified algorithm core
    """
    core_function, _, core_name = core
    packed = list(packed)
    unpacked = list()
    print("Attempting %s decompression" % core_name)
    try:
        while len(unpacked) < unpacked_size:
            core_function(packed, unpacked)
    except IndexError:
        print("  Decompression failed: Ran out of compressed data")
        return None

    if len(unpacked) != unpacked_size:
        print("  Decompression failed: Too much decompressed data")
        return None

    # If we have only zero-bytes left over and less than 16 of them,
    # we assume it's padding and let it slide
    if len(packed) > 15 or any(packed):
        print("  Decompression failed: Leftover compressed data")
        return None

    print("  Decompression successful!")
    return unpacked

if __name__ == '__main__':
    packed_data = binascii.unhexlify(input("packed data: "))
    unpacked_size = int(input("unpacked size: "), 0)

    if unpacked_size == len(packed_data):
        print("Initialization data packed size equals unpacked size, assuming no compression")
        unpacked_data = packed_data
    else:
        print("Uncompressing initialization data")
        for core in unpack_cores:
            unpacked_data = unpack(packed_data, unpacked_size, core)
            if unpacked_data is not None:
                break
        else:
            print("Failed to uncompress initialization data")
            sys.exit(1)

    filename = tempfile.mktemp() + '.bin'
    with open(filename, "w+b") as f:
        f.write(bytes(unpacked_data))

    print("Decompression successful, decompressed data saved to " + filename)

