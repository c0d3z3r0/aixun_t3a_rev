#!/bin/sh

# converts full flash image to update image

[ ! -f "${1}" ] && echo "Usage: mkupdateimage.sh <bin>" && exit 1

# image header
dd if="${1}" of="${1}.update" bs=1 skip=$((0x3f800)) count=$((0x100))

# copy main image without bootloader
dd if="${1}" of="${1}.update" bs=1 skip=$((0x10000)) seek=$((0x100)) conv=notrunc
