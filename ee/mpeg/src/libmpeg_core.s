# _____     ___ ____     ___ ____
#  ____|   |    ____|   |        | |____|
# |     ___|   |____ ___|    ____| |    \    PS2DEV Open Source Project.
#-----------------------------------------------------------------------
# Copyright (c) 2006-2007 Eugene Plotnikov <e-plotnikov@operamail.com>
# Licenced under Academic Free License version 2.0
# Review ps2sdk README & LICENSE files for further details.

.set noreorder
.set nomacro

.globl _MPEG_Initialize
.globl _MPEG_Destroy
.globl _MPEG_GetBits
.globl _MPEG_ShowBits
.globl _MPEG_AlignBits
.globl _MPEG_NextStartCode
.globl _MPEG_SetDefQM
.globl _MPEG_SetQM
.globl _MPEG_GetMBAI
.globl _MPEG_GetMBType
.globl _MPEG_GetMotionCode
.globl _MPEG_GetDMVector
.globl _MPEG_SetIDCP
.globl _MPEG_SetQSTIVFAS
.globl _MPEG_SetPCT
.globl _MPEG_BDEC
.globl _MPEG_WaitBDEC
.globl _MPEG_put_block_fr
.globl _MPEG_put_block_fl
.globl _MPEG_put_block_il
.globl _MPEG_add_block_frfr
.globl _MPEG_add_block_ilfl
.globl _MPEG_add_block_frfl
.globl _MPEG_dma_ref_image
.globl _MPEG_do_mc
.globl _MPEG_put_luma
.globl _MPEG_put_chroma
.globl _MPEG_put_luma_X
.globl _MPEG_put_chroma_X
.globl _MPEG_put_luma_Y
.globl _MPEG_put_chroma_Y
.globl _MPEG_put_luma_XY
.globl _MPEG_put_chroma_XY
.globl _MPEG_avg_luma
.globl _MPEG_avg_chroma
.globl _MPEG_avg_luma_X
.globl _MPEG_avg_chroma_X
.globl _MPEG_avg_luma_Y
.globl _MPEG_avg_chroma_Y
.globl _MPEG_avg_luma_XY
.globl _MPEG_avg_chroma_XY
.globl _MPEG_CSCImage
.globl _MPEG_Suspend
.globl _MPEG_Resume

.sdata
.align 4
s_DefQM:    .word 0x13101008, 0x16161310, 0x16161616, 0x1B1A181A
            .word 0x1A1A1B1B, 0x1B1B1A1A, 0x1D1D1D1B, 0x1D222222
            .word 0x1B1B1D1D, 0x20201D1D, 0x26252222, 0x22232325
            .word 0x28262623, 0x30302828, 0x38382E2E, 0x5345453A
            .word 0x10101010, 0x10101010, 0x10101010, 0x10101010

.section ".sbss"
.align 6
s_DMAPack : .space 128
s_DataBuf : .space   8
s_SetDMA  : .space   8
s_IPUState: .space  32
s_pEOF    : .space   4
s_Sema    : .space   4
s_CSCParam: .space  12
s_CSCID   : .space   4
s_CSCFlag : .space   1

.text

_MPEG_Initialize:
    addiu   $sp, $sp, -48
    lui     $v0, 0x1000
    lui     $v1, 0x4000
    sw      $a1, s_SetDMA + 0
    sw      $v1, 0x2010($v0)
    sw      $a2, s_SetDMA + 4
    sw      $a3, s_pEOF
1:
    lw      $v1, 0x2010($v0)
    bltz    $v1, 1b
    nop
    sw      $zero, 0x2000($v0)
1:
    lw      $v1, 0x2010($v0)
    bltz    $v1, 1b
    nop
    .set push
    .set noat
    lui     $at, 0x0080
    sw      $ra, 0($sp)
    or      $v1, $v1, $at
    .set pop
    sw      $v1, 0x2010($v0)
    lui     $v0, 0x1001
    sw      $zero, -20448($v0)
    sw      $zero, -19424($v0)
    sw      $zero, 0($a3)
    sw      $zero, 12($sp)
    addiu   $v1, $zero, 64
    addu    $a0, $sp, 4
    syscall
    sw      $v0, s_Sema
    addiu   $a0, $zero,  3
    addiu   $v1, $zero, 18
    lui     $a1, %hi( _mpeg_dmac_handler )
    la      $a3, s_CSCParam
    xor     $a2, $a2, $a2
    addiu   $a1, %lo( _mpeg_dmac_handler )
    lw      $ra, 0($sp)
    syscall
    addiu   $sp, $sp, 48
    sw      $v0, s_CSCID
    jr      $ra
    sd      $zero, s_DataBuf

_MPEG_Destroy:
1:
    lb      $v1, s_CSCFlag
    bne     $v1, $zero, 1b
    lw      $a1, s_CSCID
    addiu   $a0, $zero, 3
    addiu   $v1, $zero, 19
    syscall
    addiu   $v1, $zero, 65
    lw      $a0, s_Sema
    syscall
    jr      $ra

_MPEG_Suspend:
1:
    lb      $v0, s_CSCFlag
    bne     $v0, $zero, 1b
_ipu_suspend:
    lui     $a1, 0x1001
    lui     $v0, 0x0001
1:
    di
    sync.p
    .set push
    .set noat
    mfc0    $at, $12
    and     $at, $at, $v0
    bne     $at, $zero, 1b
    .set pop
    lui     $v0, 0x0001
    lw      $a2, -2784($a1)
    nor     $v1, $v0, $zero
    or      $a2, $a2, $v0
    sw      $a2, -2672($a1)
    .set push
    .set noat
    lw      $at, -19456($a1)
    sra     $a3, $v1, 8
    subu    $9, $a1, $v0
    and     $at, $at, $a3
    sw      $at, -19456($a1)
    lw      $a2, -2784($a1)
    sw      $at, s_IPUState + 0
    .set pop
    and     $a2, $a2, $v1
    sw      $a2, -2672($a1)
    ei
    .set push
    .set noat
    lw      $at, -19440($a1)
    lw      $a2, -19424($a1)
    sw      $at, s_IPUState + 4
    .set pop
    sw      $a2, s_IPUState + 8
1:
    .set push
    .set noat
    lw      $at, 0x2010($9)
    andi    $at, $at, 0x00F0
    bne     $at, $zero, 1b
    .set pop
    nop
1:
    di
    sync.p
    .set push
    .set noat
    mfc0    $at, $12
    and     $at, $at, $v0
    bne     $at, $zero, 1b
    .set pop
    nop
    lw      $a2, -2784($a1)
    or      $a2, $a2, $v0
    sw      $a2, -2672($a1)
    .set push
    .set noat
    lw      $at, -20480($a1)
    and     $at, $at, $a3
    sw      $at, -20480($a1)
    lw      $a2, -2784($a1)
    sw      $at, s_IPUState + 12
    .set pop
    and     $a2, $a2, $v1
    sw      $a2, -2672($a1)
    ei
    .set push
    .set noat
    lw      $at, -20464($a1)
    lw      $a2, -20448($a1)
    sw      $at, s_IPUState + 16
    .set pop
    sw      $a2, s_IPUState + 20
    .set push
    .set noat
    lw      $at, 0x2010($9)
    lw      $a2, 0x2020($9)
    sw      $at, s_IPUState + 24
    .set pop
    jr      $ra
    sw      $a2, s_IPUState + 28

_MPEG_Resume:
_ipu_resume:
    lw      $v1, s_IPUState + 20
    lui     $a0, 0x1001
    lui     $a1, 0x1000
    addiu   $a2, $zero, 0x0100
    beq     $v1, $zero, 1f
    lw      $at, s_IPUState + 28
    lw      $a3, s_IPUState + 12
    lw      $v0, s_IPUState + 16
    sw      $v0, -20464($a0)
    or      $a3, $a3, $a2
    sw      $v1, -20448($a0)
    sw      $a3, -20480($a0)
1:
    lw      $a3, s_IPUState + 8
    andi    $v0, $at, 0x007F
    srl     $v1, $at, 16
    srl     $at, $at,  8
    andi    $v1, $v1, 0x0003
    andi    $at, $at, 0x000F
    addu    $v1, $v1, $at
    lw      $at, s_IPUState + 4
    addu    $a3, $a3, $v1
    beq     $a3, $zero, 2f
    sll     $v1, $v1, 4
    subu    $at, $at, $v1
    sw      $v0, 0x2000($a1)
    lw      $v1, s_IPUState + 0
1:
    lw      $v0, 0x2010($a1)
    bltz    $v0, 1b
    nop
    lw      $v0, s_IPUState + 24
    or      $v1, $v1, $a2
    sw      $v0, 0x2010($a1)
    sw      $at, -19440($a0)
    .set pop
    sw      $a3, -19424($a0)
    sw      $v1, -19456($a0)
2:
    jr      $ra
    addiu   $v0, $v0, 1

_mpeg_dmac_handler:
    lw      $at, 8($a1)
    beql    $at, $zero, 1f
    addiu   $v1, $zero, -29
    lw      $a0, 0($a1)
    lw      $a2, 4($a1)
    addiu   $a3, $zero, 1023
    addiu   $v1, $zero,  384
    pminw   $a3, $a3, $at
    lui     $9, 0x1001
    sll     $v0, $a3, 10
    mult    $v1, $v1, $a3
    subu    $at, $at, $a3
    sw      $a2, -20464($9)
    sw      $a0, -19440($9)
    addu    $a2, $a2, $v0
    srl     $v0, $v0, 4
    addu    $a0, $a0, $v1
    sw      $a0, 0($a1)
    srl     $v1, $v1, 4
    sw      $a2, 4($a1)
    lui     $8, 0x1000
    sw      $at, 8($a1)
    sw      $v0, -20448($9)
    lui     $v0, 0x7000
    sw      $v1, -19424($9)
    addiu   $v1, $zero, 0x0101
    or      $v0, $v0, $a3
    sw      $v1, -19456($9)
    andi    $v1, 0x0100
    sw      $v0, 0x2000($8)
    sw      $v1, -20480($9)
    jr      $ra
    nor     $v0, $zero, $zero
1:
    addiu   $a0, $zero, 3
    syscall
    lw      $a0, s_Sema
    addiu   $v1, $zero, -67
    syscall
    sb      $zero, s_CSCFlag
    jr      $ra
    nor     $v0, $zero, $zero

_MPEG_CSCImage:
    addiu   $sp, $sp, -16
    sw      $ra,  0($sp)
    sw      $a0,  4($sp)
    sw      $a1,  8($sp)
    bgezal  $zero, _ipu_suspend
    sw      $a2, 12($sp)
    sw      $zero, 0x2000($9)
    addiu   $8, $zero, 1023
    addiu   $v0, $zero,    8
    addiu   $a0, $zero,    3
    addiu   $v1, $zero,   22
    lw      $a2, 12($sp)
    addiu   $11, $zero,  384
    sw      $v0, -8176($a1)
    pminw   $8, $8, $a2
    lw      $12, 4($sp)
    lw      $a3, 8($sp)
    subu    $a2, $a2, $8
    mult    $11, $11, $8
    sll     $13, $8, 10
    sw      $a3, -20464($a1)
    sw      $12, -19440($a1)
    sw      $a2, s_CSCParam + 8
    addu    $12, $12, $11
    addu    $a3, $a3, $13
    sw      $12, s_CSCParam
    srl     $11, $11, 4
    sw      $a3, s_CSCParam + 4
    srl     $13, $13, 4
    sw      $11, -19424($a1)
    sw      $13, -20448($a1)
    sw      $8, 4($sp)
    syscall
    lw      $8, 4($sp)
    addiu   $v1, $zero, 0x0101
    lui     $at, 0x1001
    lui     $v0, 0x7000
    lui     $a0, 0x1000
    or      $v0, $v0, $8
    sw      $v1, -19456($at)
    andi    $v1, $v1, 0x0100
    sw      $v0, 0x2000($a0)
    sw      $v1, -20480($at)
    lw      $a0, s_Sema
    addiu   $v1, $zero, 68
    sb      $v1, s_CSCFlag
    syscall
    lw      $ra, 0($sp)
    beq     $zero, $zero, _ipu_resume
    addiu   $sp, $sp, 16
1:
    lw      $v1, 0x2010($at)
_ipu_sync:
    lui     $a1, 0x0003
    andi    $a2, $a0, 0xFF00
    and     $v0, $a0, $a1
    andi    $a0, $a0, 0x007F
    addiu   $a1, $zero, 0x4000
    srl     $a2, $a2, 1
    srl     $v0, $v0, 9
    and     $a1, $a1, $v1
    addu    $a2, $a2, $v0
    subu    $a2, $a2, $a0
    bne     $a1, $zero, 3f
    slti    $a2, $a2, 32
    beq     $a2, $zero, 2f
    lui     $a2, 0x1001
    lw      $a2, -19424($a2)
    bgtzl   $a2, 1b
    lw      $a0, 0x2020($at)
    addiu   $sp, $sp, -16
    lw      $a2, s_SetDMA + 0
    sw      $ra, 0($sp)
    jalr    $a2
    lw      $a0, s_SetDMA + 4
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 16
    beql    $v0, $zero, 4f
    lw      $v1, s_pEOF
    lui     $at, 0x1000
2:
    lw      $v1, 0x2010($at)
    bltzl   $v1, _ipu_sync
    lw      $a0, 0x2020($at)
3:
    jr      $ra
4:
    addiu   $a0, $zero, 32
    addiu   $v0, $zero, 0x01B7
    sw      $a0, s_DataBuf
    sw      $v0, s_DataBuf + 4
    jr      $ra
    sw      $a0, 0($v1)

_ipu_sync_data:
    lui     $at, 0x1000
    ld      $v0, 0x2000($at)
    bltzl   $v0, 1f
    lw      $a0, 0x2020($at)
    jr      $ra
1:
    lui     $a1, 0x0003
    andi    $v1, $a0, 0xFF00
    and     $v0, $a0, $a1
    srl     $v1, $v1, 1
    srl     $v0, $v0, 9
    addu    $v1, $v1, $v0
    andi    $a0, $a0, 0x7F
    subu    $v0, $v1, $a0
    sltiu   $v0, $v0, 32
    beq     $v0, $zero, 2f
    lui     $v0, 0x1001
    lw      $v0, -19424($v0)
    bgtzl   $v0, 1b
    lw      $a0, 0x2020($at)
    lw      $v0, s_SetDMA + 0
    addiu   $sp, $sp, -16
    sw      $ra, 0($sp)
    jalr    $v0
    lw      $a0, s_SetDMA + 4
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 16
    beql    $v0, $zero, 4b
    lw      $v1, s_pEOF
    lui     $at, 0x1000
2:
    ld      $v0, 0x2000($at)
    bltzl   $v0, 1b
    lw      $a0, 0x2020($at)
    jr      $ra

_MPEG_GetBits:
_ipu_get_bits:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sd      $ra, 0($sp)
    sd      $s0, 8($sp)
    addu    $s0, $zero, $a0
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lw      $v1, s_DataBuf + 0
    slt     $v0, $v1, $s0
    beqzl   $v0, 1f
    lw      $v0, s_DataBuf + 4
    lui     $at, 0x1000
    lui     $a1, 0x4000
    bgezal  $zero, _ipu_sync_data
    sw      $a1, 0x2000($at)
    addiu   $v1, $zero, 32
1:
    lui     $a1, 0x4000
    or      $a1, $a1, $s0
    subu    $v1, $v1, $s0
    sw      $a1, 0x2000($at)
    sw      $v1, s_DataBuf + 0
    subu    $a2, $zero, $s0
    sllv    $v1, $v0, $s0
    srlv    $v0, $v0, $a2
    sw      $v1, s_DataBuf + 4
    ld      $ra, 0($sp)
    ld      $s0, 8($sp)
    jr      $ra
    addiu   $sp, $sp, 16

_MPEG_ShowBits:
_ipu_show_bits:
    lw      $v1, s_DataBuf + 0
    slt     $v0, $v1, $a0
    beqzl   $v0, 1f
    lw      $v0, s_DataBuf + 4
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    sw      $a0, 4($sp)
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lui     $at, 0x1000
    lui     $a1, 0x4000
    bgezal  $zero, _ipu_sync_data
    sw      $a1, 0x2000($at)
    addiu   $v1, $zero, 32
    sw      $v1, s_DataBuf + 0
    sw      $v0, s_DataBuf + 4
    lw      $ra, 0($sp)
    lw      $a0, 4($sp)
    addiu   $sp, $sp, 16
1:
    subu    $a0, $zero, $a0
    jr      $ra
    srlv    $v0, $v0, $a0

_MPEG_AlignBits:
_ipu_align_bits:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lw      $a0, 0x2020($at)
    andi    $a0, $a0, 7
    subu    $a0, $zero, $a0
    andi    $a0, $a0, 7
    beq     $a0, $zero, 1f
    lw      $ra, 0($sp)
    beq     $zero, $zero, _ipu_get_bits
1:
    addiu   $sp, $sp, 16
    jr      $ra
    nop

_MPEG_NextStartCode:
    addiu   $sp, $sp, -16
    sw      $ra, 0($sp)
    bgezal  $zero, _ipu_align_bits
    nop
1:
    bgezal  $zero, _ipu_show_bits
    addiu   $a0, $zero, 24
    addiu   $v1, $zero, 1
4:
    bne     $v0, $v1, 5f
    addiu   $a0, $zero, 32
    lw      $ra, 0($sp)
    beq     $zero, $zero, _ipu_show_bits
    addiu   $sp, $sp, 16
5:
    bgezal  $zero, _ipu_get_bits
    addiu   $a0, $zero, 8
    beq     $zero, $zero, 1b
    nop

_MPEG_SetDefQM:
    addiu   $sp, $sp, -16
    sw      $ra, 0($sp)
    bgezal  $zero, _ipu_suspend
    nop
    lui     $v1, 0x1000
    la      $at, s_DefQM
    sw      $zero, 0x2000($v1)
    lq      $a0,  0($at)
    lq      $a1, 16($at)
    lq      $a2, 32($at)
    lq      $a3, 48($at)
    lq      $8, 64($at)
    lui     $v0, 0x5000
1:
    lw      $at, 0x2010($v1)
    bltz    $at, 1b
    nop
    sq      $a0, 0x7010($v1)
    sq      $a1, 0x7010($v1)
    sq      $a2, 0x7010($v1)
    sq      $a3, 0x7010($v1)
    sw      $v0, 0x2000($v1)
    lui     $v0, 0x5800
1:
    lw      $at, 0x2010($v1)
    bltz    $at, 1b
    nop
    sq      $8, 0x7010($v1)
    sq      $8, 0x7010($v1)
    sq      $8, 0x7010($v1)
    sq      $8, 0x7010($v1)
    sw      $v0, 0x2000($v1)
1:
    lw      $at, 0x2010($v1)
    bltz    $at, 1b
    nop
    lw      $ra, 0($sp)
    beq     $zero, $zero, _ipu_resume
    addiu   $sp, $sp, 16

_MPEG_SetQM:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    sd      $s0, 8($sp)
    sll     $s0, $a0, 27
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lui     $a0, 0x5000
    or      $a0, $a0, $s0
    sw      $a0, 0x2000($at)
    lw      $ra, 0($sp)
    ld      $s0, 8($sp)
    addiu   $sp, $sp, 16
    jr      $ra
    sd      $zero, s_DataBuf

_MPEG_GetMBAI:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    sd      $s0, 8($sp)
    addu    $s0, $zero, $zero
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
3:
    lui     $v0, 0x3000
4:
    bgezal  $zero, _ipu_sync_data
    sw      $v0, 0x2000($at)
    beql    $v0, $zero, 1f
    addu    $s0, $zero, $zero
    andi    $v0, $v0, 0xFFFF
    slti    $v1, $v0, 0x0022
    bnel    $v1, $zero, 2f
    addu    $s0, $s0, $v0
    addiu   $v1, $zero, 0x0023
    beql    $v0, $v1, 3b
    addiu   $s0, $s0, 0x0021
    beq     $zero, $zero, 4b
    lui     $v0, 0x3000
2:
    addiu   $v1, $zero, 32
    ld      $a0, 0x2030($at)
    sw      $v1, s_DataBuf + 0
    sw      $a0, s_DataBuf + 4
1:
    addu    $v0, $zero, $s0
    lw      $ra, 0($sp)
    ld      $s0, 8($sp)
    jr      $ra
    addiu   $sp, $sp, 16

_MPEG_GetMBType:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lui     $a2, 0x3400
    bgezal  $zero, _ipu_sync_data
    sw      $a2, 0x2000($at)
    beq     $v0, $zero, 1f
    addiu   $v1, $zero, 32
    ld      $a1, 0x2030($at)
    andi    $v0, $v0, 0xFFFF
    sw      $v1, s_DataBuf + 0
    sw      $a1, s_DataBuf + 4
1:
    lw      $ra, 0($sp)
    jr      $ra
    addiu   $sp, $sp, 16

_MPEG_GetMotionCode:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lui     $a2, 0x3800
    bgezal  $zero, _ipu_sync_data
    sw      $a2, 0x2000($at)
    beql    $v0, $zero, 1f
    addiu   $v0, $zero, 0x8000
    addiu   $v1, $zero, 32
    ld      $a1, 0x2030($at)
    andi    $v0, $v0, 0xFFFF
    sw      $v1, s_DataBuf + 0
    sw      $a1, s_DataBuf + 4
1:
    dsll32  $v0, $v0, 16
    lw      $ra, 0($sp)
    dsra32  $v0, $v0, 16
    jr      $ra
    addiu   $sp, $sp, 16

_MPEG_GetDMVector:
    lui     $at, 0x1000
    addiu   $sp, $sp, -16
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lui     $a2, 0x3C00
    bgezal  $zero, _ipu_sync_data
    sw      $a2, 0x2000($at)
    addiu   $v1, $zero, 32
    ld      $a1, 0x2030($at)
    dsll32  $v0, $v0, 16
    sw      $v1, s_DataBuf + 0
    sw      $a1, s_DataBuf + 4
    lw      $ra, 0($sp)
    dsra32  $v0, $v0, 16
    jr      $ra
    addiu   $sp, $sp, 16

_MPEG_SetIDCP:
    addiu   $sp, $sp, -16
    sw      $ra, 0($sp)
    bgezal  $zero, _ipu_get_bits
    addiu   $a0, $zero, 2
    lui     $v1, 0xFFFC
    sll     $v0, $v0, 16
    lw      $a0, 0x2010($at)
    ori     $v1, $v1, 0xFFFF
    lw      $ra, 0($sp)
    and     $a0, $a0, $v1
    addiu   $sp, $sp, 16
    or      $a0, $a0, $v0
    jr      $ra
    sw      $a0, 0x2010($at)

_MPEG_SetQSTIVFAS:
    addiu   $sp, $sp, -16
    sd      $ra, 0($sp)
    sd      $s0, 8($sp)
    bgezal  $zero, _ipu_get_bits
    addiu   $a0, $zero, 1
    sll     $s0, $v0, 22
    bgezal  $zero, _ipu_get_bits
    addiu   $a0, $zero, 1
    sll     $v0, $v0, 21
    addiu   $a0, $zero, 1
    bgezal  $zero, _ipu_get_bits
    or      $s0, $s0, $v0
    sll     $v0, $v0, 20
    lw      $a0, 0x2010($at)
    lui     $v1, 0xFF8F
    or      $s0, $s0, $v0
    ori     $v1, $v1, 0xFFFF
    ld      $ra, 0($sp)
    and     $a0, $a0, $v1
    addiu   $sp, $sp, 16
    or      $a0, $a0, $s0
    ld      $s0, -8($sp)
    jr      $ra
    sw      $a0, 0x2010($at)

_MPEG_SetPCT:
    sll     $a0, $a0, 24
    addiu   $sp, $sp, -16
    lui     $at, 0x1000
    sw      $ra, 0($sp)
    sw      $a0, 4($sp)
    lw      $v1, 0x2010($at)
    bltzl   $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lw      $v0, 4($sp)
    lui     $a0, 0xF8FF
    ori     $a0, $a0, 0xFFFF
    and     $v1, $v1, $a0
    or      $v1, $v1, $v0
    lw      $ra, 0($sp)
    addiu   $sp, $sp, 16
    jr      $ra
    sw      $v1, 0x2010($at)

_MPEG_BDEC:
    addiu   $sp, $sp, -16
    sll     $a0, $a0, 27
    sd      $ra, 0($sp)
    sll     $a1, $a1, 26
    sd      $s0, 8($sp)
    lui     $s0, 0x2000
    sll     $a2, $a2, 25
    or      $s0, $s0, $a0
    sll     $a3, $a3, 16
    or      $s0, $s0, $a1
    lui     $a0, 0x8000
    or      $s0, $s0, $a2
    sll     $8, $8, 4
    or      $s0, $s0, $a3
    srl     $8, $8, 4
    lui     $a1, 0x1001
    lui     $at, 0x1000
    or      $8, $8, $a0
    lw      $v1, 0x2010($at)
    addiu   $a0, $zero, 48
    addiu   $a2, $zero, 0x0100
    sw      $8, -20464($a1)
    sw      $a0, -20448($a1)
    sw      $a2, -20480($a1)
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    ld      $ra, 0($sp)
    sw      $s0, 0x2000($at)
    ld      $s0, 8($sp)
    jr      $ra
    addiu   $sp, $sp, 16

_MPEG_WaitBDEC:
    addiu   $sp, $sp, -16
    lui     $at, 0x1000
    lw      $v1, 0x2010($at)
    sw      $ra, 0($sp)
1:
    bltzall $v1, _ipu_sync
    lw      $a0, 0x2020($at)
    lw      $v1, s_pEOF
    addiu   $a0, $zero, 0x4000
    lw      $v1, 0($v1)
    lui     $a2, 0x1001
    bne     $v1, $zero, 3f
    lw      $v0, 0x2010($at)
    and     $v0, $v0, $a0
    bne     $v0, $zero, 3f
    lw      $a2, -20448($a2)
    addiu   $v0, $zero, 1
    bnel    $a2, $zero, 1b
    lw      $v1, 0x2010($at)
    ld      $v1, 0x2030($at)
    addiu   $ra, $zero, 32
    addiu   $v0, $zero, 1
    pextlw  $v1, $v1, $ra
2:
    lw      $ra, 0($sp)
    sd      $v1, s_DataBuf
    jr      $ra
    addiu   $sp, $sp, 16
3:
    bgezal  $zero, _ipu_suspend
    lui     $8, 0x4000
    bgezal  $zero, _ipu_resume
    sw      $8, 0x2010($9)
    lui     $v0, 0x0001
4:
    di
    sync.p
    mfc0    $at, $12
    and     $at, $at, $v0
    nor     $a2, $v0, $zero
    bne     $at, $zero, 4b
    lw      $at, -2784($a0)
    xor     $v1, $v1, $v1
    or      $at, $at, $v0
    sw      $at, -2672($a0)
    sw      $zero, -20480($a0)
    lw      $at, -2784($a0)
    xor     $v0, $v0, $v0
    and     $at, $at, $a2
    sw      $at, -2672($a0)
    ei
    beq     $zero, $zero, 2b
    sw      $zero, -20448($a0)

_MPEG_put_block_fr:
    lw      $a2, 0($a0)
    lw      $a3, 8($a0)
    pnor    $v0, $zero, $zero
    addiu   $v1, $zero, 6
    psrlh   $v0, $v0, 8
1:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1;
    lq      $12,  64($a3)
    lq      $13,  80($a3)
    lq      $14,  96($a3)
    lq      $15, 112($a3)
    addiu   $a3, $a3, 128
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $8,  0($a2)
    sq      $10, 16($a2)
    sq      $12, 32($a2)
    sq      $14, 48($a2)
    bgtzl   $v1, 1b
    addiu   $a2, $a2, 64
    jr      $ra

_MPEG_put_block_fl:
    pnor    $v0, $zero, $zero
    lw      $a2, 0($a0)
    lw      $a3, 8($a0)
    addiu   $v1, $zero, 4
    psrlh   $v0, $v0, 8
1:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1
    lq      $12, 256($a3)
    lq      $13, 272($a3)
    lq      $14, 288($a3)
    lq      $15, 304($a3)
    addiu   $a3, $a3, 64
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $8,  0($a2)
    sq      $12, 16($a2)
    sq      $10, 32($a2)
    sq      $14, 48($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 64
    addiu   $v1, $v1, 2
2:
    lq      $8, 256($a3)
    lq      $9, 272($a3)
    lq      $10, 288($a3)
    lq      $11, 304($a3)
    addiu   $v1, $v1, -1
    lq      $12, 320($a3)
    lq      $13, 336($a3)
    lq      $14, 352($a3)
    lq      $15, 368($a3)
    addiu   $a3, $a3, 128
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $8,  0($a2)
    sq      $10, 16($a2)
    sq      $12, 32($a2)
    sq      $14, 48($a2)
    bgtzl   $v1, 2b
    addiu   $a2, $a2, 64
    jr      $ra

_MPEG_put_block_il:
    pnor    $v0, $zero, $zero
    lw      $a2,  0($a0)
    lw      $a3,  8($a0)
    lw      $at, 24($a0)
    addiu   $v1, $zero, 4
    psrlh   $v0, $v0, 8
    addu    $at, $at, $a2
1:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1
    lq      $12, 256($a3)
    lq      $13, 272($a3)
    lq      $14, 288($a3)
    lq      $15, 304($a3)
    addiu   $a3, $a3, 64
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $8,  0($a2)
    sq      $10, 32($a2)
    addiu   $a2, $a2, 64
    sq      $12,  0($at)
    sq      $14, 32($at)
    bgtzl   $v1, 1b
    addiu   $at, $at, 64
    lw      $a2,  4($a0)
    lw      $at, 24($a0)
    addiu   $v1, $zero, 2
    addu    $at, $at, $a2
2:
    lq      $8, 256($a3)
    lq      $9, 272($a3)
    lq      $10, 288($a3)
    lq      $11, 304($a3)
    addiu   $v1, $v1, -1
    lq      $12, 320($a3)
    lq      $13, 336($a3)
    lq      $14, 352($a3)
    lq      $15, 368($a3)
    addiu   $a3, $a3, 128
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $8, $zero, $8
    ppacb   $9, $zero, $9
    ppacb   $10, $zero, $10
    ppacb   $11, $zero, $11
    ppacb   $12, $zero, $12
    ppacb   $13, $zero, $13
    ppacb   $14, $zero, $14
    ppacb   $15, $zero, $15
    sd      $8,  0($a2)
    sd      $9, 16($a2)
    sd      $10, 32($a2)
    sd      $11, 48($a2)
    sd      $12,  0($at)
    sd      $13, 16($at)
    sd      $14, 32($at)
    sd      $15, 48($at)
    addiu   $a2, $a2, 64
    bgtzl   $v1, 2b
    addiu   $at, $at, 64
    jr      $ra

_MPEG_add_block_frfr:
    pnor    $v0, $zero, $zero
    lw      $a2,  0($a0)
    lw      $a3, 12($a0)
    lw      $a0, 16($a0)
    addiu   $v1, $zero, 6
    psrlh   $v0, $v0, 8
1:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1
    lq      $12,   0($a0)
    lq      $13,  16($a0)
    lq      $14,  32($a0)
    lq      $15,  48($a0)
    paddh   $8, $8, $12
    paddh   $9, $9, $13
    paddh   $10, $10, $14 
    paddh   $11, $11, $15
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    sq      $8,  0($a2)
    sq      $10, 16($a2)
    lq      $12,  64($a3)
    lq      $13,  80($a3)
    lq      $14,  96($a3)
    lq      $15, 112($a3)
    addiu   $a3, $a3, 128
    lq      $8,  64($a0)
    lq      $9,  80($a0)
    lq      $10,  96($a0)
    lq      $11, 112($a0)
    addiu   $a0, $a0, 128
    paddh   $12, $12, $8
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $15, $15, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $12, 32($a2)
    sq      $14, 48($a2)
    bgtzl   $v1, 1b
    addiu   $a2, $a2, 64
    jr      $ra

_MPEG_add_block_ilfl:
    pnor    $v0, $zero, $zero
    lw      $a2,  0($a0)
    lw      $a3, 12($a0)
    lw      $at, 24($a0)
    lw      $a1, 16($a0)
    addiu   $v1, $zero, 4
    psrlh   $v0, $v0, 8
    addu    $at, $at, $a2
1:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1
    lq      $12,   0($a1)
    lq      $13,  16($a1)
    lq      $14,  32($a1)
    lq      $15,  48($a1)
    paddh   $8, $8, $12
    paddh   $9, $9, $13
    paddh   $10, $10, $14
    paddh   $11, $11, $15
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    sq      $8,   0($a2)
    sq      $10,  32($a2)
    lq      $12, 256($a3)
    lq      $13, 272($a3)
    lq      $14, 288($a3)
    lq      $15, 304($a3)
    addiu   $a3, $a3, 64
    lq      $8, 256($a1)
    lq      $9, 272($a1)
    lq      $10, 288($a1)
    lq      $11, 304($a1)
    paddh   $12, $12, $8
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $15, $15, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $12,  0($at)
    sq      $14, 32($at)
    addiu   $at, $at, 64
    addiu   $a1, $a1, 64
    bgtzl   $v1, 1b
    addiu   $a2, $a2, 64
    lw      $a2,  4($a0)
    lw      $at, 24($a0)
    addiu   $v1, $zero, 2
    addu    $at, $at, $a2
2:
    lq      $8, 256($a3)
    lq      $9, 272($a3)
    lq      $10, 288($a3)
    lq      $11, 304($a3)
    addiu   $v1, $v1, -1
    lq      $12, 256($a1)
    lq      $13, 272($a1)
    lq      $14, 288($a1)
    lq      $15, 304($a1)
    paddh   $8, $8, $12
    paddh   $9, $9, $13
    paddh   $10, $10, $14
    paddh   $11, $11, $15
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    ppacb   $8, $zero, $8
    ppacb   $9, $zero, $9
    ppacb   $10, $zero, $10
    ppacb   $11, $zero, $11
    sd      $8,  0($a2)
    sd      $9, 16($a2)
    sd      $10, 32($a2)
    sd      $11, 48($a2)
    lq      $12, 320($a3)
    lq      $13, 336($a3)
    lq      $14, 352($a3)
    lq      $15, 368($a3)
    addiu   $a3, $a3, 128
    lq      $8, 320($a1)
    lq      $9, 336($a1)
    lq      $10, 352($a1)
    lq      $11, 368($a1)
    paddh   $12, $12, $8
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $15, $15, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $12, $zero, $12
    ppacb   $13, $zero, $13
    ppacb   $14, $zero, $14
    ppacb   $15, $zero, $15
    sd      $12,  0($at)
    sd      $13, 16($at)
    sd      $14, 32($at)
    sd      $15, 48($at)
    addiu   $a2, $a2, 64
    addiu   $at, $at, 64
    bgtzl   $v1, 2b
    addiu   $a1, $a1, 128
    jr      $ra

_MPEG_add_block_frfl:
    pnor    $v0, $zero, $zero
    lw      $a2,  0($a0)
    lw      $a3, 12($a0)
    lw      $a1, 16($a0)
    addiu   $v1, $zero, 4
    psrlh   $v0, $v0, 8
1:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1
    lq      $12,   0($a1)
    lq      $13,  16($a1)
    lq      $14, 256($a1)
    lq      $15, 272($a1)
    paddh   $8, $8, $12
    paddh   $9, $9, $13
    paddh   $10, $10, $14
    paddh   $11, $11, $15
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    sq      $8,   0($a2)
    sq      $10,  16($a2)
    lq      $12,  64($a3)
    lq      $13,  80($a3)
    lq      $14,  96($a3)
    lq      $15, 112($a3)
    addiu   $a3, $a3, 128
    lq      $8,  32($a1)
    lq      $9,  48($a1)
    lq      $10, 288($a1)
    lq      $11, 304($a1)
    paddh   $12, $12, $8
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $15, $15, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $12, 32($a2)
    sq      $14, 48($a2)
    addiu   $a1, $a1, 64
    bgtzl   $v1, 1b
    addiu   $a2, $a2, 64
    lw      $a2, 4($a0)
    addiu   $v1, $zero, 2
2:
    lq      $8,   0($a3)
    lq      $9,  16($a3)
    lq      $10,  32($a3)
    lq      $11,  48($a3)
    addiu   $v1, $v1, -1
    lq      $12, 256($a1)
    lq      $13, 320($a1)
    lq      $14, 272($a1)
    lq      $15, 336($a1)
    paddh   $8, $8, $12
    paddh   $9, $9, $13
    paddh   $10, $10, $14
    paddh   $11, $11, $15
    pmaxh   $8, $zero, $8
    pmaxh   $9, $zero, $9
    pmaxh   $10, $zero, $10
    pmaxh   $11, $zero, $11
    pminh   $8, $v0, $8
    pminh   $9, $v0, $9
    pminh   $10, $v0, $10
    pminh   $11, $v0, $11
    ppacb   $8, $9, $8
    ppacb   $10, $11, $10
    sq      $8,  0($a2)
    sq      $10, 16($a2)
    lq      $12,  64($a3)
    lq      $13,  80($a3)
    lq      $14,  96($a3)
    lq      $15, 112($a3)
    addiu   $a3, $a3, 128
    lq      $8, 288($a1)
    lq      $9, 352($a1)
    lq      $10, 304($a1)
    lq      $11, 368($a1)
    paddh   $12, $12, $8
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $15, $15, $11
    pmaxh   $12, $zero, $12
    pmaxh   $13, $zero, $13
    pmaxh   $14, $zero, $14
    pmaxh   $15, $zero, $15
    pminh   $12, $v0, $12
    pminh   $13, $v0, $13
    pminh   $14, $v0, $14
    pminh   $15, $v0, $15
    ppacb   $12, $13, $12
    ppacb   $14, $15, $14
    sq      $12, 32($a2)
    sq      $14, 48($a2)
    addiu   $a2, $a2, 64
    bgtzl   $v1, 2b
    addiu   $a1, $a1, 128
    jr      $ra

_MPEG_dma_ref_image:
    addiu   $at, $zero, 4
    pminw   $a2, $a2, $at
    bgtzl   $a2, 1f
    addiu   $at, $at, 380
    jr      $ra
1:
    lui     $v0, 0x1001
    mult    $a3, $a3, $at
    sll     $at, $a0, 4
    lui     $9, 0x2000
    la      $8, s_DMAPack
1:
    lw      $v1, -11264($v0)
    andi    $v1, $v1, 0x0100
    bne     $v1, $zero, 1b
    nop
    srl     $at, $at, 4
    sw      $zero, -11232($v0)
    or      $9, $9, $8
    sw      $at, -11136($v0)
    lui     $v1, 0x3000
    sw      $8, -11216($v0)
    ori     $v1, $v1, 0x0030
1:
    lw      $8, 0($a1)
    addiu   $a2, $a2, -1
    sw      $v1,  0($9)
    sw      $8,  4($9)
    addu    $8, $8, $a3
    sw      $v1, 16($9)
    sw      $8, 20($9)
    sw      $a0, 0($a1)
    addiu   $a1, $a1, 40
    addiu   $9, $9, 32
    bgtz    $a2, 1b
    addiu   $a0, $a0, 1536
    andi    $v1, $v1, 0xFFFF
    addiu   $at, $zero, 0x0105
    sw      $v1, -16($9)
    sw      $zero, 32($a1)
    sync.l
    jr      $ra
    sw      $at, -11264($v0)

_MPEG_do_mc:
    addiu   $v0, $zero, 16
    lw      $a1,  0($a0)
    addiu   $sp, $sp, -16
    lw      $a2,  4($a0)
    lw      $a3, 12($a0)
    lw      $8, 16($a0)
    lw      $9, 20($a0)
    lw      $10, 24($a0)
    lw      $12, 28($a0)
    subu    $8, $8, $12
    lw      $13, 32($a0)
    sll     $12, $12, 4
    addu    $a1, $a1, $12
    subu    $v1, $v0, $8
    sllv    $11, $v0, $10
    srlv    $v1, $v1, $10
    sll     $at, $8, 4
    sw      $ra, 0($sp)
    addu    $a1, $a1, $at
    jalr    $13
    subu    $at, $9, $v1
    lw      $a1,  0($a0)
    lw      $a2,  8($a0)
    lw      $13, 36($a0)
    addiu   $a1, $a1, 256
    srl     $12, $12, 1
    srl     $a3, $a3, 1
    srl     $8, $8, 1
    srl     $9, $9, 1
    lw      $ra, 0($sp)
    srlv    $8, $8, $10
    addu    $a1, $a1, $12
    addiu   $v0, $zero, 8
    sllv    $8, $8, $10
    subu    $v1, $v0, $8
    sllv    $11, $v0, $10
    srlv    $v1, $v1, $10
    sll     $at, $8, 3
    addu    $a1, $a1, $at
    subu    $at, $9, $v1
    jr      $13
    addiu   $sp, $sp, 16

_MPEG_put_luma:
    mtsab   $a3, 0
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $13, $14, $13
    pextlb  $14, $zero, $13
    pextub  $13, $zero, $13
    sq      $14,  0($a2)
    sq      $13, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_chroma:
    mtsab   $a3, 0
1:
    ld      $13,   0($a1)
    ld      $14,  64($a1)
    ld      $15, 384($a1)
    ld      $24, 448($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    pcpyld  $13, $15, $13
    pcpyld  $14, $24, $14
    qfsrv   $13, $13, $13
    qfsrv   $14, $14, $14
    pextlb  $13, $zero, $13
    pextlb  $14, $zero, $14
    sq      $13,   0($a2)
    sq      $14, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_luma_X:
    pnor    $v0, $zero, $zero
    psrlh   $v0, $v0, 15
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    mtsab   $a3, 0
    qfsrv   $15, $14, $13
    qfsrv   $24, $13, $14
    pextlb  $13, $zero, $15
    pextub  $14, $zero, $15
    addu    $a1, $a1, $11
    mtsab   $zero, 1
    addiu   $v1, $v1, -1
    qfsrv   $24, $24, $15
    pextlb  $15, $zero, $24
    pextub  $24, $zero, $24
    paddh   $13, $13, $15
    paddh   $14, $14, $24
    paddh   $13, $13, $v0
    paddh   $14, $14, $v0
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    sq      $13,  0($a2)
    sq      $14, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_chroma_X:
    pnor    $v0, $zero, $zero
    psrlh   $v0, $v0, 15
1:
    ld      $13,   0($a1)
    ld      $14,  64($a1)
    ld      $15, 384($a1)
    ld      $24, 448($a1)
    pcpyld  $13, $15, $13
    pcpyld  $14, $24, $14
    mtsab   $a3, 0
    qfsrv   $13, $13, $13
    qfsrv   $14, $14, $14
    addiu   $25, $zero, 1
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    mtsab   $25, 0
    qfsrv   $9, $13, $13
    qfsrv   $10, $14, $14
    pextlb  $13, $zero, $13
    pextlb  $14, $zero, $14
    pextlb  $9, $zero, $9
    pextlb  $10, $zero, $10
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $13, $13, $v0
    paddh   $14, $14, $v0
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    sq      $13,   0($a2)
    sq      $14, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_luma_Y:
    mtsab   $a3, 0
    lq      $15,   0($a1)
    lq      $24, 384($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $15, $24, $15
    pextub  $24, $zero, $15
    pextlb  $15, $zero, $15
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $13, $14, $13
    pextub  $14, $zero, $13
    pextlb  $13, $zero, $13
    paddh   $v0, $14, $24
    pnor    $24, $zero, $zero
    paddh   $25, $13, $15
    psrlh   $24, $24, 15
    por     $15, $zero, $13
    paddh   $25, $25, $24
    paddh   $v0, $v0, $24
    por     $24, $zero, $14
    psrlh   $25, $25, 1
    psrlh   $v0, $v0, 1
    sq      $25,  0($a2)
    sq      $v0, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_chroma_Y:
    mtsab   $a3, 0
    ld      $a0,   0($a1)
    ld      $a3,  64($a1)
    ld      $8, 384($a1)
    ld      $9, 448($a1)
    pnor    $v0, $zero, $zero
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    psrlh   $v0, $v0, 15
    pcpyld  $a0, $8, $a0
    pcpyld  $a3, $9, $a3
    qfsrv   $a0, $a0, $a0
    qfsrv   $a3, $a3, $a3
    pextlb  $a0, $zero, $a0
    pextlb  $a3, $zero, $a3
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    ld      $13,   0($a1)
    ld      $14,  64($a1)
    ld      $15, 384($a1)
    ld      $24, 448($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    pcpyld  $13, $15, $13
    pcpyld  $14, $24, $14
    qfsrv   $13, $13, $13
    qfsrv   $14, $14, $14
    pextlb  $13, $zero, $13
    pextlb  $14, $zero, $14
    paddh   $9, $13, $a0
    paddh   $10, $14, $a3
    por     $a0, $zero, $13
    por     $a3, $zero, $14
    paddh   $9, $9, $v0
    paddh   $10, $10, $v0
    psrlh   $9, $9, 1
    psrlh   $10, $10, 1
    sq      $9,   0($a2)
    sq      $10, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_luma_XY:
    mtsab   $a3, 0
    lq      $v0,   0($a1)
    lq      $15, 384($a1)
    addu    $a1, $a1, $11
    qfsrv   $24, $15, $v0
    qfsrv   $25, $v0, $15
    addiu   $v1, $v1, -1
    pextlb  $v0, $zero, $24
    pextub  $15, $zero, $24
    mtsab   $zero, 1
    qfsrv   $25, $25, $24
    pextlb  $24, $zero, $25
    pextub  $25, $zero, $25
    paddh   $v0, $v0, $24
    paddh   $15, $15, $25
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    mtsab   $a3, 0
    addu    $a1, $a1, $11
    qfsrv   $24, $14, $13
    qfsrv   $25, $13, $14
    addiu   $v1, $v1, -1
    pextlb  $13, $zero, $24
    pextub  $14, $zero, $24
    mtsab   $zero, 1
    qfsrv   $25, $25, $24
    pextlb  $24, $zero, $25
    pextub  $25, $zero, $25
    paddh   $13, $13, $24
    paddh   $14, $14, $25
    paddh   $24, $v0, $13
    paddh   $25, $15, $14
    por     $v0, $zero, $13
    pnor    $13, $zero, $zero
    por     $15, $zero, $14
    psrlh   $13, $13, 15
    psllh   $13, $13,  1
    paddh   $24, $24, $13
    paddh   $25, $25, $13
    psrlh   $24, $24, 2
    psrlh   $25, $25, 2
    sq      $24,  0($a2)
    sq      $25, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_put_chroma_XY:
    mtsab   $a3, 0
    pnor    $25, $zero, $zero
    ld      $a0,   0($a1)
    ld      $v0,  64($a1)
    mtsab   $zero, 1
    ld      $8, 384($a1)
    ld      $9, 448($a1)
    pcpyld  $a0, $8, $a0
    pcpyld  $v0, $9, $v0
    qfsrv   $a0, $a0, $a0
    qfsrv   $v0, $v0, $v0
    psrlh   $25, $25, 15
    psllh   $25, $25, 1
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $8, $a0, $a0
    qfsrv   $9, $v0, $v0
    pextlb  $a0, $zero, $a0
    pextlb  $v0, $zero, $v0
    pextlb  $8, $zero, $8
    pextlb  $9, $zero, $9
    paddh   $a0, $a0, $8
    paddh   $8, $v0, $9
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    ld      $13,   0($a1)
    ld      $15,  64($a1)
    mtsab   $a3, 0
    ld      $14, 384($a1)
    ld      $24, 448($a1)
    pcpyld  $13, $14, $13
    pcpyld  $15, $24, $15
    qfsrv   $13, $13, $13
    qfsrv   $15, $15, $15
    addiu   $v0, $zero, 1
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    mtsab   $v0, 0
    qfsrv   $14, $13, $13
    qfsrv   $24, $15, $15
    pextlb  $13, $zero, $13
    pextlb  $15, $zero, $15
    pextlb  $14, $zero, $14
    pextlb  $24, $zero, $24
    paddh   $13, $13, $14
    paddh   $14, $15, $24
    paddh   $15, $a0, $13
    paddh   $24, $8, $14
    por     $a0, $zero, $13
    por     $8, $zero, $14
    paddh   $15, $15, $25
    paddh   $24, $24, $25
    psrlh   $15, $15, 2
    psrlh   $24, $24, 2
    sq      $15,   0($a2)
    sq      $24, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_luma:
    mtsab   $a3, 0
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $13, $14, $13
    pextlb  $14, $zero, $13
    pextub  $13, $zero, $13
    lq      $24,  0($a2)
    lq      $25, 16($a2)
    paddh   $14, $14, $24
    paddh   $13, $13, $25
    pcgth   $24, $14, $zero
    pcgth   $25, $13, $zero
    pceqh   $v0, $14, $zero
    pceqh   $15, $13, $zero
    psrlh   $24, $24, 15
    psrlh   $25, $25, 15
    psrlh   $v0, $v0, 15
    psrlh   $15, $15, 15
    por     $24, $24, $v0
    por     $25, $25, $15
    paddh   $14, $14, $24
    paddh   $13, $13, $25
    psrlh   $14, $14, 1
    psrlh   $13, $13, 1
    sq      $14,  0($a2)
    sq      $13, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_chroma:
    mtsab   $a3, 0
1:
    ld      $13,   0($a1)
    ld      $14,  64($a1)
    addiu   $v1, $v1, -1
    ld      $15, 384($a1)
    ld      $24, 448($a1)
    addu    $a1, $a1, $11
    pcpyld  $13, $15, $13
    pcpyld  $14, $24, $14
    qfsrv   $13, $13, $13
    qfsrv   $14, $14, $14
    pextlb  $13, $zero, $13
    pextlb  $14, $zero, $14
    lq      $8,   0($a2)
    lq      $9, 128($a2)
    paddh   $13, $13, $8
    paddh   $14, $14, $9
    pcgth   $8, $13, $zero
    pcgth   $9, $14, $zero
    pceqh   $v0, $13, $zero
    pceqh   $25, $14, $zero
    psrlh   $8, $8, 15
    psrlh   $9, $9, 15
    psrlh   $v0, $v0, 15
    psrlh   $25, $25, 15
    por     $8, $8, $v0
    por     $9, $9, $25
    paddh   $13, $13, $8
    paddh   $14, $14, $9
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    sq      $13,   0($a2)
    sq      $14, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_luma_X:
    pnor    $v0, $zero, $zero
    psrlh   $v0, $v0, 15
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    mtsab   $a3, 0
    qfsrv   $15, $14, $13
    qfsrv   $24, $13, $14
    pextlb  $13, $zero, $15
    pextub  $14, $zero, $15
    addu    $a1, $a1, $11
    mtsab   $zero, 1
    addiu   $v1, $v1, -1
    qfsrv   $24, $24, $15
    pextlb  $15, $zero, $24
    pextub  $24, $zero, $24
    paddh   $13, $13, $15
    paddh   $14, $14, $24
    paddh   $13, $13, $v0
    paddh   $14, $14, $v0
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    lq      $24,  0($a2)
    lq      $25, 16($a2)
    paddh   $13, $13, $24
    paddh   $14, $14, $25
    pcgth   $24, $13, $zero
    pceqh   $25, $13, $zero
    psrlh   $24, $24, 15
    psrlh   $25, $25, 15
    por     $24, $24, $25
    paddh   $13, $13, $24
    pcgth   $24, $14, $zero
    pceqh   $25, $14, $zero
    psrlh   $24, $24, 15
    psrlh   $25, $25, 15
    por     $24, $24, $25
    paddh   $14, $14, $24
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    sq      $13,  0($a2)
    sq      $14, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_chroma_X:
    pnor    $v0, $zero, $zero
    psrlh   $v0, $v0, 15
1:
    ld      $13,   0($a1)
    ld      $14,  64($a1)
    mtsab   $a3, 0
    ld      $15, 384($a1)
    ld      $24, 448($a1)
    pcpyld  $13, $15, $13
    pcpyld  $14, $24, $14
    qfsrv   $13, $13, $13
    qfsrv   $14, $14, $14
    addiu   $25, $zero, 1
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    mtsab   $25, 0
    qfsrv   $9, $13, $13
    qfsrv   $10, $14, $14
    pextlb  $13, $zero, $13
    pextlb  $14, $zero, $14
    pextlb  $9, $zero, $9
    pextlb  $10, $zero, $10
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    paddh   $13, $13, $v0
    paddh   $14, $14, $v0
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    lq      $9,   0($a2)
    lq      $10, 128($a2)
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    pcgth   $9, $13, $zero
    pcgth   $10, $14, $zero
    pceqh   $25, $13, $zero
    pceqh   $a0, $14, $zero
    psrlh   $9, $9, 15
    psrlh   $10, $10, 15
    psrlh   $25, $25, 15
    psrlh   $a0, $a0, 15
    por     $9, $9, $25
    por     $10, $10, $a0
    paddh   $13, $13, $9
    paddh   $14, $14, $10
    psrlh   $13, $13, 1
    psrlh   $14, $14, 1
    sq      $13,   0($a2)
    sq      $14, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_luma_Y:
    mtsab   $a3, 0
    lq      $15,   0($a1)
    lq      $24, 384($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $15, $24, $15
    pextub  $24, $zero, $15
    pextlb  $15, $zero, $15
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $13, $14, $13
    pextub  $14, $zero, $13
    pextlb  $13, $zero, $13
    paddh   $v0, $14, $24
    pnor    $24, $zero, $zero
    paddh   $25, $13, $15
    psrlh   $24, $24, 15
    por     $15, $zero, $13
    paddh   $25, $25, $24
    paddh   $v0, $v0, $24
    por     $24, $zero, $14
    psrlh   $25, $25, 1
    psrlh   $v0, $v0, 1
    lq      $13,  0($a2)
    lq      $14, 16($a2)
    paddh   $25, $25, $13
    paddh   $v0, $v0, $14
    pcgth   $13, $25, $zero
    pceqh   $14, $25, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $25, $25, $13
    pcgth   $13, $v0, $zero
    pceqh   $14, $v0, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $v0, $v0, $13
    psrlh   $25, $25, 1
    psrlh   $v0, $v0, 1
    sq      $25,  0($a2)
    sq      $v0, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_chroma_Y:
    mtsab   $a3, 0
    ld      $a0,   0($a1)
    ld      $a3,  64($a1)
    ld      $8, 384($a1)
    ld      $9, 448($a1)
    pnor    $v0, $zero, $zero
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    psrlh   $v0, $v0, 15
    pcpyld  $a0, $8, $a0
    pcpyld  $a3, $9, $a3
    qfsrv   $a0, $a0, $a0
    qfsrv   $a3, $a3, $a3
    pextlb  $a0, $zero, $a0
    pextlb  $a3, $zero, $a3
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    ld      $13,   0($a1)
    ld      $14,  64($a1)
    addiu   $v1, $v1, -1
    ld      $15, 384($a1)
    ld      $24, 448($a1)
    addu    $a1, $a1, $11
    pcpyld  $13, $15, $13
    pcpyld  $14, $24, $14
    qfsrv   $13, $13, $13
    qfsrv   $14, $14, $14
    pextlb  $13, $zero, $13
    pextlb  $14, $zero, $14
    paddh   $9, $13, $a0
    paddh   $10, $14, $a3
    por     $a0, $zero, $13
    por     $a3, $zero, $14
    paddh   $9, $9, $v0
    paddh   $10, $10, $v0
    psrlh   $9, $9, 1
    psrlh   $10, $10, 1
    lq      $13,   0($a2)
    lq      $14, 128($a2)
    paddh   $9, $9, $13
    paddh   $10, $10, $14
    pcgth   $13, $9, $zero
    pceqh   $14, $9, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $9, $9, $13
    pcgth   $13, $10, $zero
    pceqh   $14, $10, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $10, $10, $13
    psrlh   $9, $9, 1
    psrlh   $10, $10, 1
    sq      $9,   0($a2)
    sq      $10, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_luma_XY:
    mtsab   $a3, 0
    lq      $v0,   0($a1)
    lq      $15, 384($a1)
    addu    $a1, $a1, $11
    qfsrv   $24, $15, $v0 
    qfsrv   $25, $v0, $15
    addiu   $v1, $v1, -1
    pextlb  $v0, $zero, $24
    pextub  $15, $zero, $24
    mtsab   $zero, 1
    qfsrv   $25, $25, $24
    pextlb  $24, $zero, $25
    pextub  $25, $zero, $25
    paddh   $v0, $v0, $24
    paddh   $15, $15, $25
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    lq      $13,   0($a1)
    lq      $14, 384($a1)
    mtsab   $a3, 0
    addu    $a1, $a1, $11 
    qfsrv   $24, $14, $13
    qfsrv   $25, $13, $14
    addiu   $v1, $v1, -1
    pextlb  $13, $zero, $24
    pextub  $14, $zero, $24
    mtsab   $zero, 1
    qfsrv   $25, $25, $24
    pextlb  $24, $zero, $25
    pextub  $25, $zero, $25
    paddh   $13, $13, $24
    paddh   $14, $14, $25
    paddh   $24, $v0, $13
    paddh   $25, $15, $14
    por     $v0, $zero, $13
    pnor    $13, $zero, $zero
    por     $15, $zero, $14
    psrlh   $13, $13, 15
    psllh   $13, $13,  1
    paddh   $24, $24, $13
    paddh   $25, $25, $13
    psrlh   $24, $24, 2
    psrlh   $25, $25, 2
    lq      $13,  0($a2)
    lq      $14, 16($a2)
    paddh   $24, $24, $13
    paddh   $25, $25, $14
    pcgth   $13, $24, $zero
    pceqh   $14, $24, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $24, $24, $13
    pcgth   $13, $25, $zero
    pceqh   $14, $25, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $25, $25, $13
    psrlh   $24, $24, 1
    psrlh   $25, $25, 1
    sq      $24,  0($a2)
    sq      $25, 16($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 32
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 512
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra

_MPEG_avg_chroma_XY:
    mtsab   $a3, 0
    pnor    $25, $zero, $zero
    ld      $a0,   0($a1)
    ld      $v0,  64($a1)
    mtsab   $zero, 1
    ld      $8, 384($a1)
    ld      $9, 448($a1)
    pcpyld  $a0, $8, $a0
    pcpyld  $v0, $9, $v0
    qfsrv   $a0, $a0, $a0
    qfsrv   $v0, $v0, $v0
    psrlh   $25, $25, 15
    psllh   $25, $25,  1
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    qfsrv   $8, $a0, $a0
    qfsrv   $9, $v0, $v0
    pextlb  $a0, $zero, $a0
    pextlb  $v0, $zero, $v0
    pextlb  $8, $zero, $8
    pextlb  $9, $zero, $9
    paddh   $a0, $a0, $8
    paddh   $8, $v0, $9
    beq     $v1, $zero, 2f
    addiu   $at, $at, 1
1:
    ld      $13,   0($a1)
    ld      $15,  64($a1)
    mtsab   $a3, 0
    ld      $14, 384($a1)
    ld      $24, 448($a1)
    pcpyld  $13, $14, $13
    pcpyld  $15, $24, $15
    qfsrv   $13, $13, $13
    qfsrv   $15, $15, $15
    addiu   $v0, $zero, 1
    addu    $a1, $a1, $11
    addiu   $v1, $v1, -1
    mtsab   $v0, 0
    qfsrv   $14, $13, $13
    qfsrv   $24, $15, $15
    pextlb  $13, $zero, $13
    pextlb  $15, $zero, $15
    pextlb  $14, $zero, $14
    pextlb  $24, $zero, $24
    paddh   $13, $13, $14
    paddh   $14, $15, $24
    paddh   $15, $a0, $13
    paddh   $24, $8, $14
    por     $a0, $zero, $13
    por     $8, $zero, $14
    paddh   $15, $15, $25
    paddh   $24, $24, $25
    psrlh   $15, $15, 2
    psrlh   $24, $24, 2
    lq      $13,   0($a2)
    lq      $14, 128($a2)
    paddh   $15, $15, $13
    paddh   $24, $24, $14
    pcgth   $13, $15, $zero
    pceqh   $14, $15, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $15, $15, $13
    pcgth   $13, $24, $zero
    pceqh   $14, $24, $zero
    psrlh   $13, $13, 15
    psrlh   $14, $14, 15
    por     $13, $13, $14
    paddh   $24, $24, $13
    psrlh   $15, $15, 1
    psrlh   $24, $24, 1
    sq      $15,   0($a2)
    sq      $24, 128($a2)
    bgtz    $v1, 1b
    addiu   $a2, $a2, 16
2:
    addu    $v1, $zero, $at
    addiu   $a1, $a1, 704
    bgtzl   $v1, 1b
    addu    $at, $zero, $zero
    jr      $ra
    nop

