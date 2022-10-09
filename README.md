# AIXUN T3A Reverse Engineering

Notes, scripts, dumps etc. from RE'ing the AIXUN T3A soldering station.

## Schematics

For schematics see [c0d3z3r0/aixun_t3a_schematics](https://github.com/c0d3z3r0/aixun_t3a_schematics).

## Firmware dumps / images

files in `bin/`:

- `JC_M_T3A_v1.26.bin`: extracted firmware image from update tool
- `JC_M_T3AS_v1.26.bin`: extracted firmware image from update tool
- `t3a_dump_v1.26.bin`: dumped via SWD (see below)
- `t3a_dump_sram_init_boot_v1.26.bin`: SRAM content written by armlib/Keil init code (bootloader)
- `t3a_dump_sram_init_main_v1.26.bin`: SRAM content written by armlib/Keil init code (main firmware)

T3AS firmware is for GD32F305/GD32F307 version of the board, which wasn't released (yet?).

## Debugging with OpenOCD

```sh
openocd -f ft4232h_swd.cfg -f target/stm32f3x.cfg
```

Dumping flash:

Read protection is *not* enabled! :-)

```sh
telnet localhost 4444
flash read_bank 0 firmware2.bin 0 0x40000
```

## Notes

- MCU is GD32F303RCT6 (STM32 clone) https://www.gd32mcu.com/en/download/0?kw=GD32F3
- USB 0403:6001 (FTDI fake device)
- Firmware based on GD32 fw library 2.1.0, probably Keil MDK

Firmware update log:

```
>JC_version
<00160000JC_M_T3A_version1.01
>0x0002d100JC_M_T3A_version1.01
>update_jcxx
>... 2048 bytes from fw image ...
<ack_jcxx
>... 2048 bytes from fw image ...
<ack_jcxx
>...
<...
>... last 256 bytes from fw image ...
<ack_jcxx
```
