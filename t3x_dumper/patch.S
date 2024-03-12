# dumper for T3x
.text

.org OFFSET_MEMCPY
memcpy:

.org OFFSET_FUNC_RET
func_ret:

.org OFFSET_DUMPER
compare_dump:
    movs    r2, #4
    adr     r1, str_dump
   #mov     r0, r4/r10
   #bl      strncmp
   #cbnz    r0, <next_cmd>

.org OFFSET_DUMPER+0x0c
# force update mode on next boot, just in case...
    movs    r2, #16
    adr     r1, str_jcid_update_mode
    ldr     r0, =0x2000bc00
    bl      memcpy

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

    movs    r0, #1
    bl      func_ret

.ltorg
.align
str_dump:
    .asciz "dump"
.align
str_jcid_update_mode:
    .asciz "jcid_update_mode"

.org OFFSET_CDC_ACM
cdc_acm_data_send:
