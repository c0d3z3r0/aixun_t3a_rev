#!/bin/sh

# converts update to full flash image

[ ! -f "${1}" ] && echo "Usage: mkfullimage_t3b.sh <JC_M_T3B_v1.xx.bin>" && exit 1

echo "${1}.full"
head -c $((0x40000)) /dev/zero | tr '\000' '\377' >"${1}.full"

# bootloader
dd if="bin/t3b_boot_v0.04.bin" of="${1}.full" bs=1 count=$((0x10000)) conv=notrunc

# main image from update
dd if="${1}" of="${1}.full" bs=1 skip=$((0x100)) seek=$((0x10000)) conv=notrunc

# image header from update
dd if="${1}" of="${1}.full" bs=1 seek=$((0x3f800)) count=$((0x100)) conv=notrunc

# drm magic
echo -n 'jc__aixun_zxc_t3b_20210805163200' | dd of="${1}.full" bs=1 seek=$((0x3f000)) conv=notrunc
