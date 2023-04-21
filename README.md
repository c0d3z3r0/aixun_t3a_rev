# AIXUN T3A Reverse Engineering

Notes, schematics, scripts, dumps etc. from RE'ing the AIXUN T3A soldering station.

## Firmware dumps / images

files in `bin/`:

- `JC_M_T3A_v1.XX.bin`: extracted firmware image from update tool
- `JC_M_T3AS_v1.XX.bin`: extracted firmware image from update tool
- `t3a_dump_v1.26.bin`: dumped via SWD (see below, contains remnants from earlier fw version)
- `t3a_dump_cleaned_v1.26.bin`: `t3a_dump_v1.26.bin` with cleaned padding regions, settings etc.
- `t3a_dump_boot_v1.26.idb`: IDA Pro project, bootloader (finished)
- `t3a_dump_main_v1.26.idb`: IDA Pro project, main firmware (not yet finished)
- `t3a_dump_sram_init_boot_v1.26.bin`: SRAM content written by armlib/Keil init code (bootloader)
- `t3a_dump_sram_init_main_v1.26.bin`: SRAM content written by armlib/Keil init code (main firmware)

T3AS firmware is for GD32F305/GD32F307 version of the board, which was [released](https://www.aixuntech.com/newsinfo/aixun-new-product-launch-t3as-allinone-200w-soldering-station/) in February of 2023.

## Constructing full flash image from dump


There's a script for that task!

```
$ ./mkfullimage.sh bin/JC_M_T3A_v1.26.bin
$ sha1sum bin/t3a_dump_cleaned_v1.26.bin bin/JC_M_T3A_v1.26.bin.full
15f8ccb768084515bc211185abf7d536e74791fc  bin/t3a_dump_cleaned_v1.26.bin
15f8ccb768084515bc211185abf7d536e74791fc  bin/JC_M_T3A_v1.26.bin.full
```

## Flash / firmware image address map

dumped flash image:

```
0x0000_0000 - 0x0000_a5ff	bootloader
0x0000_a600 - 0x0000_afff	padding
0x0000_b000 - 0x0000_dd7f	custom startup image region
  0x0000_b000 - 0x0000_b7ff	custom startup image signature
  0x0000_b800 - 0x0000_dd7f	custom startup image data (9600 bytes)
  0x0000_dd80 - 0x0000_dfff	padding
0x0000_e000 - 0x000_ffff	padding
0x0001_0000 - 0x0003_e800	main firmware max size (0x2e800, boot loader limit)
  0x0001_0000 - 0x0003_cfff	main firmware (fw v1.26)
  0x0003_d000 - 0x0003_dfff	padding (fw v1.26)
  0x0003_e000 - 0x0003_e7e7	settings (23 banks of 88 bytes each)
  0x0003_e7e8 - 0x0003_e7ff	padding
0x0003_e800 - 0x0003_e803	language flag (0 = chinese, 1 = english)
0x0003_f000 - 0x0003_f01f	hmac_sha3_256(key='jcid_zxc_t3a_2021041016-20210415', message=$DEVICE_ID) <- silly "DRM" :'D
0x0003_f020 - 0x0003_f7ff	padding
0x0003_f800 - 0x0003_f865	firmware signature (fw image header)
```

downloaded firmware image, v1.26:

```
0x0000_0000 - 0x0000_0065	firmware signature / header
0x0000_0066 - 0x0000_00ff	padding
0x0000_0100 - 0x0002_d0ff	main firmware
```

Firmware signature:

```
0x00 - 0x03:	vendor string: `JCID`
0x04 - 0x1f:	padding
0x20 - ....:	product string: `JC_M_T3A`
.... - 0x3f:	padding
0x40 - 0x4a:	version string: `version1.26`
0x4b - 0x5f:	padding
0x60 - 0x63:	image size, big endian
0x64 - 0x65:	Modbus RTU CRC-16 (see `crc.py`)
0x66 - 0xff:	padding
```

## Debugging with OpenOCD

```sh
openocd -f openocd_ft4232h_swd.cfg
```

Dumping flash:

Read protection is *not* enabled! :-)

```sh
openocd -f openocd_ft4232h_swd.cfg -c "init; reset halt; flash read_bank 0 firmware_dump.bin 0 0x40000; exit"
```

Flashing:

```sh
openocd -f openocd_ft4232h_swd.cfg -c "init; reset halt; flash write_image erase firmware.bin 0x08000000; reset run; exit"
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

## Patching firmware

Take a look at the stuff in patch/.

