# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# customdata.inc -- record macros for the custom-data flash (CUSTOM STYLE memory):
# the KN7000's IC21 bank at 0x96820000 and the KN6000/KN6500's IC18 equivalent.
# Used by the generated sources kn7000/src/customdata/*.s and kn6000/src/customdata/*.s.
# Format and evidence: kn7000/notes/custom-data-ic21.md.  Every field the firmware is
# known to read is a named parameter; the program addresses are KN7000 build 941.
#
# Byte order: the directory and the slot-record header are little-endian (the MN10300
# reads them with plain mov/movbu); every field inside the "TCMP" and "TPAD" containers
# is BIG-endian (LoadU24BE 0x48440363 / LoadU16BE 0x4844038B).

.equ CUSTOM_BLOCK, 0x8000              # allocation unit: slot n's block b is at bank + b<<15 (func_48483FED)
.equ CUSTOM_STYLE_SOURCE, 0x00200000   # style-ID source field "CUSTOM" (func_4843E452: slot | 0x200000)

# ---- big-endian fields ---------------------------------------------------------------
.macro BE16 v
    .byte ((\v) >> 8) & 0xff, (\v) & 0xff
.endm
.macro BE24 v
    .byte ((\v) >> 16) & 0xff, ((\v) >> 8) & 0xff, (\v) & 0xff
.endm

# ---- the directory: block 0 of the bank (RAM shadow 0x5037A000, 0x6000 bytes) -----------
# func_48484499 builds an empty one: 0x6000 bytes of 0xFF, "IK", every slot {0, 0}, every
# block free, then block 0 marked used; FlashProgram128Words writes it back.
.macro CUSTDIR_SIGNATURE
    .ascii "IK"                        # 0x49 0x4B, checked by func_48484499
.endm
# One of the 20 slot descriptors at +0x02 + slot*2: the first block (func_48483F53;
# 0 = empty slot) and the number of blocks (func_48483F82) of the slot's record.
.macro CUSTDIR_SLOT first, blocks
    .byte \first, \blocks
.endm
# The 60-entry block map at +0x2A (func_48483FB4 reads, func_48483FC6 / func_48483FDA set
# and clear): 1 = the 0x8000-byte block is allocated.  Ten blocks per use.
.macro CUSTDIR_BLOCKS b0, b1, b2, b3, b4, b5, b6, b7, b8, b9
    .byte \b0, \b1, \b2, \b3, \b4, \b5, \b6, \b7, \b8, \b9
.endm

# ---- the slot record: one custom style with everything it depends on --------------------
# Written by the MEMORY -> CUSTOM save (func_484854E3, KN7000 0x484854E3), read through the
# accessors func_48483FFC..func_4848435C.
#   +0x00 u32   record size (func_4848403C), = 0x100 + every section below
.macro CSTREC_SIZE size
    .long \size
.endm
#   +0x04       the style's name, then the four ONE TOUCH SETTING names (16 bytes each,
#               func_48484049 / 7B / B1 / E7 / 1D return +0x04/+0x14/+0x24/+0x34/+0x44)
.macro CSTREC_NAME text
    .ascii \text
.endm
#   +0x54..+0x8B  seven dependency sections, each {u32 offset (0 = none), u32 count}: five
#               kinds of 0x42-byte record, the 0x2C8-byte SOUND EDIT records
#               (CustomSoundEditRecFetch 0x484845E1) and the 0x48A7-byte custom-sound
#               block (CustomVoiceRecFetch 0x4844A42F).  The firmware reads the count's
#               low byte (movbu +0x58 ...); the save fills them from the MEMORY items the
#               style uses.
.macro CSTREC_DEPS offset, count
    .long \offset, \count
.endm
#   +0x8C / +0x94 / +0x9C  {u32 offset, u32 size} of the one-touch-setting panel memories,
#               the "TCMP" style container (CustomStyleBlockFetch 0x48484578 -> func_48484305)
#               and the "TPAD" performance-pad container (func_48484332)
.macro CSTREC_SECTION offset, size
    .long \offset, \size
.endm
#   +0xA4 / +0xA5  the record's first block and block count, as in its directory slot
.macro CSTREC_PLACE first, blocks
    .byte \first, \blocks
.endm

# ---- "TCMP" / "TPAD" N=1 containers (MemStyleExportToCustom 0x4843DEC7) -----------------
# The 0x70-byte header of the ROM templates 0x487312E8 / 0x48729858, with the checksum
# descriptor [0x06,0x10) left zero (the export clears it), the length +0x10 and the
# allocator top +0x13 both = the container size, and one style / bank (+0x16).
.macro TCMP_HEADER size
    .ascii "TCMP"
    .byte 0, 0                         # sub-signature (MemStyleAreaSignatureVerify)
    .space 10                          # checksum + descriptor: zero in an exported container
    BE24 \size                         # container length
    BE24 \size                         # allocator top: no tail slack (the byte below is 0xF5)
    BE16 1                             # style count N
    .byte 0x00, 0x60, 0x0d, 0x08, 0x04, 0x02, 0x02, 0x01, 0x02, 0x0f   # template tail +0x18
    .space 14
    .space 64, 0x20
.endm
.macro TPAD_HEADER size
    .ascii "TPAD"
    .byte 0, 0                         # sub-signature (func_48438871)
    .space 10
    BE24 \size
    BE24 \size
    BE16 1                             # bank count
    .byte 0x00, 0x60, 0x10, 0x06, 0x10, 0x02, 0x00, 0x00, 0x00, 0x0f   # template 0x48729858+0x18
    .space 14
    .space 64, 0x20
.endm

# The 0x80-byte style record at container +0x70 (CustStyleRecPtr 0x4843E107).
#   +0x00 13-byte name + 3 NUL; +0x10..+0x4F four 13-byte variation-name fields; +0x50 the
#   20 variation indices 0..19 (CustStyleImportToMem renormalises them); +0x70 two u16BE
#   fields (meaning not traced; ROM template 0x0010 0x0023).
.macro TCMP_STYLE name, vname1, vname2, vname3, vname4, w70, w72
    .ascii \name
    .ascii \vname1, \vname2, \vname3, \vname4
    .byte 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
    .space 12
    BE16 \w70
    BE16 \w72
    .space 12
.endm

# The first 0x20 bytes of a 0xE0-byte variation record (CustStyleVarRecPtr 0x4843E10C:
# container +0xF0 + var*0xE0); its eight 0x18-byte part blocks follow.
#   kind     +0x00  content byte (0x58 / 0x7C / 0x33 ... in these sets)
#   b1, b2   +0x01/+0x02  not traced
#   flags    +0x03  bit 4 = the "B" half of a paired variation (MemStyleVarRecInit)
#   p0..p7   +0x04..+0x0B  one byte per part (MemStyleVarRecInit clamps them to 1 for
#            variations 12..19)
#   bars     +0x10  \ MemStyleVarBarCount 0x4843C445: the stream holds
#   meter    +0x11  /   (bars + 1) * ((meter & 7) + 1) 0xF4 bar markers
#   stream   +0x15  u24BE offset of the variation's event stream in the container
#   t18, t19 +0x18/+0x19  not traced (0xFF 0xFF in most variations)
.macro TCMP_VAR kind, b1, b2, flags, p0, p1, p2, p3, p4, p5, p6, p7, bars, meter, stream, t18, t19
    .byte \kind, \b1, \b2, \flags
    .byte \p0, \p1, \p2, \p3, \p4, \p5, \p6, \p7
    .space 4
    .byte \bars, \meter
    .space 3
    BE24 \stream
    .byte \t18, \t19
    .space 6
.endm

# An event stream: the variation (or pad) index, the u24BE count of event bytes that
# follow (MemStyleExportSize adds LoadU24BE(stream+1) + 4), then the events: 0xF4 bar
# markers, channel events, 0xF0 SysEx, ending with 0xF5 (MemStyleAreaStreamsVerify).
.macro STREAM_HEADER index, count
    .byte \index
    BE24 \count
.endm

# The 0x30-byte bank record at TPAD +0x70: the bank name and its six pads, each
# {bank, pad, 0x20} (func_484384A3 builds the MEMORY ones with flags 0x10).
.macro TPAD_BANK name
    .ascii \name
    .byte 0, 0, 0x20, 0, 1, 0x20, 0, 2, 0x20, 0, 3, 0x20, 0, 4, 0x20, 0, 5, 0x20
    .space 14
.endm

# The first 0x28 bytes of a 0x60-byte pad record (TPAD +0xA0 + pad*0x60; the MEMORY area's
# accessor is func_48438791): the 16-byte name, thirteen setting bytes (+0x14/+0x15 one per
# part, +0x1A bit 2/3 set for pads 4 and 5 by func_484385DD), the u24BE stream offset
# (+0x1D, func_484387A9) and eight zero bytes; two 0x18-byte part blocks and eight zero
# bytes follow.
.macro TPAD_PAD name, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, stream
    .ascii \name
    .byte \s0, \s1, \s2, \s3, \s4, \s5, \s6, \s7, \s8, \s9, \s10, \s11, \s12
    BE24 \stream
    .space 8
.endm
