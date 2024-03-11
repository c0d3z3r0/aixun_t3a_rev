cp ../bin/JC_M_T3B_1.15.bin fw_t3b_patched.bin

# assemble patches
arm-none-eabi-as -mthumb -march=armv7 -mcpu=cortex-m4 patch_t3b.S -o patch_t3b.elf
arm-none-eabi-objdump -S patch_t3b.elf >patch_t3b.dmp

# apply patches
../patch/asmpatch.py patch_t3b.dmp fw_t3b_patched.bin

# recalculate checksum
../crc.py fw_t3b_patched.bin
mv fw_t3b_patched.bin.patched fw_t3b_patched.bin

echo
echo Patched firmware saved as fw_t3b_patched.bin
