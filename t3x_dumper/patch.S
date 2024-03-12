# dumper for T3x
.text

.org OFFSET_MEMCPY
memcpy:

.org OFFSET_STRCMP
strcmp:

.org OFFSET_FUNCRET1
func_ret1:

.org OFFSET_LASTCMD
    bl      dumper_init

.org OFFSET_CDC_ACM
cdc_acm_data_send:

.org OFFSET_DUMPER
dumper_init:
# force update mode on next boot, just in case...
    movs    r2, #16
    adr     r1, str_jcid_update_mode
    ldr     r0, =0x2000bc00
    bl      memcpy

# cmd == "dump"?
    movs    r2, #4
    adr     r1, str_dump
    mov     r0, r4
    bl      strcmp
    cbnz    r0, return
    b       dumper
return:
    bl      func_ret1

dumper:
    ldr     r6, =0x08000000
    ldr     r7, =0x08040000
dumper_loop:
# send data in 32 byte chunks
    movs    r1, #32
    movs    r0, r6
    bl      cdc_acm_data_send
    add     r6, #32
    cmp     r6, r7
    blt     dumper_loop

    bl      func_ret1

.ltorg
.align
str_dump:
    .ascii "dump\0"
.align
str_jcid_update_mode:
    .ascii "jcid_update_mode"
