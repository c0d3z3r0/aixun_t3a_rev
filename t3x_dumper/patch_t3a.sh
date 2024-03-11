cp ../bin/JC_M_T3A_v1.26.bin fw_t3a_patched.bin

# assemble patches
arm-none-eabi-as -mthumb -march=armv7 -mcpu=cortex-m4 patch_t3a.S -o patch_t3a.elf
arm-none-eabi-objdump -S patch_t3a.elf >patch_t3a.dmp

# apply patches
../patch/asmpatch.py patch_t3a.dmp fw_t3a_patched.bin

# recalculate checksum
../crc.py fw_t3a_patched.bin
mv fw_t3a_patched.bin.patched fw_t3a_patched.bin

echo
echo Patched firmware saved as fw_t3a_patched.bin
