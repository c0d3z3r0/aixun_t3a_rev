#!/bin/sh

# converts update to full flash image

[ -f "${1}" ] || (echo "Usage: mkfullimage.sh <JC_M_T3A_v1.xx.bin>" && exit 1)

echo "${1}.full"
head -c $((0x40000)) /dev/zero | tr '\000' '\377' >"${1}.full"

# bootloader from v1.26 dump
dd if="bin/t3a_dump_cleaned_v1.26.bin" of="${1}.full" bs=1 count=$((0x10000)) conv=notrunc

# main image from update
dd if="${1}" of="${1}.full" bs=1 skip=$((0x100)) seek=$((0x10000)) conv=notrunc

# image header from update
dd if="${1}" of="${1}.full" bs=1 seek=$((0x3f800)) count=$((0x100)) conv=notrunc

# drm magic
echo -n 'jcid_zxc_t3a_2021041016-20210415' | dd of="${1}.full" bs=1 seek=$((0x3f000)) conv=notrunc
