.text

.org 0x801abea
x801abea:
    movs    r1, #0x04	    @ disable stand gpio pull-up

.org 0x801daac
x801daac:
    bl	    lcd_init_custom @ call custom lcd init
    b	    x801dc08	    @ skip original init

.org 0x801dc08
x801dc08:

.org 0x801de1c
lcd_write_data8:

.org 0x801de50
lcd_write_cmd:

@ LCD init sequence for JLT24008D
.org 0x803d000
lcd_init_custom:
    push {lr}

    @ 0x36  <- 0x00
    @
    movs    r0,     #0x36
    bl	    lcd_write_cmd
    movs    r0,     #0
    bl      lcd_write_data8

    @ 0x3a  <- 0x55
    @ orig: <- 0x05
    @
    movs    r0,     #0x3a
    bl      lcd_write_cmd
   #movs    r0,     #0x05
    movs    r0,     #0x55
    bl      lcd_write_data8

    @ 0xb2  <- 0x0c,0x0c,0x00,0x33,0x33
    @
    movs    r0,     #0xb2
    bl      lcd_write_cmd
    movs    r0,     #0xc
    bl      lcd_write_data8
    movs    r0,     #0xc
    bl      lcd_write_data8
    movs    r0,     #0
    bl      lcd_write_data8
    movs    r0,     #0x33
    bl      lcd_write_data8
    movs    r0,     #0x33
    bl      lcd_write_data8

    @ 0xb7  <- 0x75
    @ orig: <- 0x35
    @
    movs    r0,     #0xb7
    bl      lcd_write_cmd
   #movs    r0,     #0x35
    movs    r0,     #0x75
    bl      lcd_write_data8

    @ 0xbb  <- 0x13
    @ orig: <- 0x35
    @
    movs    r0,     #0xbb
    bl      lcd_write_cmd
   #movs    r0,     #0x35
    movs    r0,     #0x13
    bl      lcd_write_data8

    @ 0xc0  <- 0x2c
    @
    movs    r0,     #0xc0
    bl      lcd_write_cmd
    movs    r0,     #0x2c
    bl      lcd_write_data8

    @ 0xc2  <- 0x01
    @
    movs    r0,     #0xc2
    bl      lcd_write_cmd
    movs    r0,     #1
    bl      lcd_write_data8

    @ 0xc3  <- 0x13
    @ orig: <- 0x0b
    @
    movs    r0,     #0xc3
    bl      lcd_write_cmd
   #movs    r0,     #0x0b
    movs    r0,     #0x13
    bl      lcd_write_data8

    @ 0xc4  <- 0x20
    @
    movs    r0,     #0xc4
    bl      lcd_write_cmd
    movs    r0,     #0x20
    bl      lcd_write_data8

    @ 0xc6  <- 0x0f
    @
    movs    r0,     #0xc6
    bl      lcd_write_cmd
    movs    r0,     #0xf
    bl      lcd_write_data8

    @ 0xd0  <- 0xa4,0xa1
    @
    movs    r0,     #0xd0
    bl      lcd_write_cmd
    movs    r0,     #0xa4
    bl      lcd_write_data8
    movs    r0,     #0xa1
    bl      lcd_write_data8

    @ 0xd6  <- 0xa1
    @ orig: noop
    @
    movs    r0,     #0xd6
    bl      lcd_write_cmd
    movs    r0,     #0xa1
    bl      lcd_write_data8

    @ 0x21
    @ orig: noop
    @
    movs    r0,     #0x21
    bl      lcd_write_cmd

    @ 0xe0   <- 0xd0,0x08,0x10,0x0d,0x0c,0x07,0x37
    @           0x53,0x4c,0x39,0x15,0x15,0x2a,0x2d
    @ orig:  <- 0xd0,0x00,0x02,0x07,0x0b,0x1a,0x31
    @           0x54,0x40,0x29,0x12,0x12,0x12,0x17
    @
   #movs    r0,     #0xe0
   #bl      lcd_write_cmd
   #movs    r0,     #0xd0
   #bl      lcd_write_data8
   #movs    r0,     #0x00
   #bl      lcd_write_data8
   #movs    r0,     #0x02
   #bl      lcd_write_data8
   #movs    r0,     #0x07
   #bl      lcd_write_data8
   #movs    r0,     #0x0b
   #bl      lcd_write_data8
   #movs    r0,     #0x1a
   #bl      lcd_write_data8
   #movs    r0,     #0x31
   #bl      lcd_write_data8
   #movs    r0,     #0x54
   #bl      lcd_write_data8
   #movs    r0,     #0x40
   #bl      lcd_write_data8
   #movs    r0,     #0x29
   #bl      lcd_write_data8
   #movs    r0,     #0x12
   #bl      lcd_write_data8
   #movs    r0,     #0x12
   #bl      lcd_write_data8
   #movs    r0,     #0x12
   #bl      lcd_write_data8
   #movs    r0,     #0x17
   #bl      lcd_write_data8

    movs    r0,     #0xe0
    bl      lcd_write_cmd
    movs    r0,     #0xd0
    bl      lcd_write_data8
    movs    r0,     #0x08
    bl      lcd_write_data8
    movs    r0,     #0x10
    bl      lcd_write_data8
    movs    r0,     #0x0d
    bl      lcd_write_data8
    movs    r0,     #0x0c
    bl      lcd_write_data8
    movs    r0,     #0x07
    bl      lcd_write_data8
    movs    r0,     #0x37
    bl      lcd_write_data8
    movs    r0,     #0x53
    bl      lcd_write_data8
    movs    r0,     #0x4c
    bl      lcd_write_data8
    movs    r0,     #0x39
    bl      lcd_write_data8
    movs    r0,     #0x15
    bl      lcd_write_data8
    movs    r0,     #0x15
    bl      lcd_write_data8
    movs    r0,     #0x2a
    bl      lcd_write_data8
    movs    r0,     #0x2d
    bl      lcd_write_data8

    @ 0xe1  <- 0xd0,0x0d,0x12,0x08,0x08,0x15,0x34
    @          0x34,0x4a,0x36,0x12,0x13,0x2b,0x2f
    @ orig: <- 0xd0,0x00,0x02,0x07,0x05,0x25,0x2d
    @       <- 0x44,0x45,0x1c,0x18,0x16,0x1c,0x1d
    @
   #movs    r0,     #0xe1
   #bl      lcd_write_cmd
   #movs    r0,     #0xd0
   #bl      lcd_write_data8
   #movs    r0,     #0x00
   #bl      lcd_write_data8
   #movs    r0,     #0x02
   #bl      lcd_write_data8
   #movs    r0,     #0x07
   #bl      lcd_write_data8
   #movs    r0,     #0x05
   #bl      lcd_write_data8
   #movs    r0,     #0x25
   #bl      lcd_write_data8
   #movs    r0,     #0x2d
   #bl      lcd_write_data8
   #movs    r0,     #0x44
   #bl      lcd_write_data8
   #movs    r0,     #0x45
   #bl      lcd_write_data8
   #movs    r0,     #0x1c
   #bl      lcd_write_data8
   #movs    r0,     #0x18
   #bl      lcd_write_data8
   #movs    r0,     #0x16
   #bl      lcd_write_data8
   #movs    r0,     #0x1c
   #bl      lcd_write_data8
   #movs    r0,     #0x1d
   #bl      lcd_write_data8
   #
    movs    r0,     #0xe1
    bl      lcd_write_cmd
    movs    r0,     #0xd0
    bl      lcd_write_data8
    movs    r0,     #0x0d
    bl      lcd_write_data8
    movs    r0,     #0x12
    bl      lcd_write_data8
    movs    r0,     #0x08
    bl      lcd_write_data8
    movs    r0,     #0x08
    bl      lcd_write_data8
    movs    r0,     #0x15
    bl      lcd_write_data8
    movs    r0,     #0x34
    bl      lcd_write_data8
    movs    r0,     #0x34
    bl      lcd_write_data8
    movs    r0,     #0x4a
    bl      lcd_write_data8
    movs    r0,     #0x36
    bl      lcd_write_data8
    movs    r0,     #0x12
    bl      lcd_write_data8
    movs    r0,     #0x13
    bl      lcd_write_data8
    movs    r0,     #0x2b
    bl      lcd_write_data8
    movs    r0,     #0x2f
    bl      lcd_write_data8

    @ 0x29
    @
    movs    r0,     #0x29
    bl      lcd_write_cmd

    pop {pc}
