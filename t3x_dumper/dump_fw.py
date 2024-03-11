#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later

__title__       = "T3x firmware dumper"
__description__ = "Dumps T3x firmware with help of patched firmware"
__author__      = "Michael Niewöhner"
__email__       = "foss@mniewoehner.de"
__license__     = 'GPL-2.0-or-later'
__copyright__   = 'Copyright (c) 2024 Michael Niewöhner'

import os
import sys
import serial
import time
import logging
from logging import debug, info, warning, error
from argparse import ArgumentParser
from serial.tools import list_ports

class T3XDumper():
    def __init__(self):
        pass

    def get_port(self):
        ports = list_ports.comports()
        port = next(filter(lambda x: x[1].startswith("JCID_T3"), ports))[0]
        if not port:
            error("No T3x found.")
            sys.exit(1)

        return port

    def connect(self):
        self.ser = serial.Serial(self.get_port(), baudrate=115200, timeout=3)

    def transfer(self, data):
        debug(f"TX: {data[:32]}{'...' if len(data) > 32 else ''}")
        self.ser.write(data)

        # first read 1 byte to use timeout mechanism
        rx  = self.ser.read(1)
        rx += self.ser.read_all().rstrip(b'\x00')

        debug(f"RX: {rx}")
        return rx

    def dump_firmware(self):
        info("Trying to dump firmware...")
        self.connect()
        self.ser.write(b'dump')
        data = self.ser.read(0x40000)

        open("fw.bin", "w+b").write(data)
        info("Firmware written to fw.bin")


def main():
    argp = ArgumentParser("T3x Dumper")
    argp.add_argument('--debug', '-d', action='store_true', help='Enable debug output')
    args = argp.parse_args()

    loglevel = logging.DEBUG if args.debug else logging.INFO
    logging.basicConfig(level=loglevel, format='%(levelname)s: %(message)s')

    t3xdumper = T3XDumper()
    t3xdumper.dump_firmware()


if __name__ == '__main__':
    main()

