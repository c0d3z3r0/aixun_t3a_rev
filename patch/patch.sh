cp ../bin/t3a_dump_cleaned_v1.26.bin fw_patched.bin

# assemble patches
arm-none-eabi-as -mthumb -march=armv7 -mcpu=cortex-m4 patch.S -o patch.elf
arm-none-eabi-objdump -S patch.elf >patch.dmp

# apply patches
./asmpatch.py patch.dmp fw_patched.bin

# recalculate checksum
../crc.py fw_patched.bin
mv fw_patched.bin.patched fw_patched.bin

echo
echo Patched firmware saved as fw_patched.bin
