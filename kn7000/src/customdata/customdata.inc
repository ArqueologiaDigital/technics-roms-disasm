# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# customdata.inc -- record macros for the custom-data flash (CUSTOM STYLE memory):
# the KN7000's IC21 bank at 0x96820000 and the KN6000/KN6500's IC18 equivalent.
# Used by the generated sources kn7000/src/customdata/ and kn6000/src/customdata/.
# Format and evidence: kn7000/notes/custom-data-ic21.md.  Every field the firmware is
# known to read is a named parameter; program addresses are KN7000 build 941's.
# [INFERENCE] marks a name no traced code fixes.
#
# Byte order: the directory and the slot-record header are little-endian (plain mov /
# movbu); every field inside the "TCMP" and "TPAD" containers is BIG-endian (LoadU24BE
# 0x48440363 / LoadU16BE 0x4844038B), spelled .be16 / .be24.
#
# The event macros (ev_*) have the names and parameters of src/ic18/rhythm.s's: the
# built-in styles use the same event stream (RhyEventLenByStatus 0x484403D5).

.equ CUSTOM_BLOCK, 0x8000              # allocation unit: block b of the bank is at bank + b<<15 (func_48483FED)

# ---- the directory: block 0 of the bank (RAM shadow 0x5037A000, 0x6000 bytes) -----------
# func_48484499 builds an empty one: 0x6000 bytes of 0xFF, "IK", every slot {0, 0}, every
# block free, then block 0 marked used; FlashProgram128Words writes it back.
.macro CUSTDIR_SIGNATURE
	.ascii	"IK"
.endm
# One of the 20 slot descriptors at +0x02 + slot*2: the record's first block (func_48483F53;
# 0 = empty slot) and its number of blocks (func_48483F82).  Each record starts with an
# .org that checks `first`.
.macro CUSTDIR_SLOT first, blocks
	.byte	\first, \blocks
.endm
# The 60-entry block map at +0x2A (func_48483FB4 reads it, func_48483FC6 / func_48483FDA set
# and clear it): 1 = the 0x8000-byte block is allocated.  Ten blocks per use.
.macro CUSTDIR_BLOCKS b0, b1, b2, b3, b4, b5, b6, b7, b8, b9
	.byte	\b0, \b1, \b2, \b3, \b4, \b5, \b6, \b7, \b8, \b9
.endm

# ---- the slot record: one custom style with everything it depends on --------------------
# Written by the MEMORY -> CUSTOM save func_484854E3, read through func_48483FFC..func_4848435C.
#   +0x00 u32  the record size (func_4848403C), 0x100 + every section below
.macro CSTREC_SIZE size
	.long	\size
.endm
#   +0x04  the style's name, then the four ONE TOUCH SETTING names, 16 bytes each
#          (func_48484049 / 7B / B1 / E7 / 1D return +0x04 / +0x14 / +0x24 / +0x34 / +0x44)
.macro CSTREC_NAME text
	.ascii	"\text"
.endm
#   +0x54..+0x8B  seven dependency sections {u32 offset, 0 = none; u32 count}: five kinds of
#          0x42-byte record, the 0x2C8-byte SOUND EDIT records (CustomSoundEditRecFetch
#          0x484845E1) and the 0x48A7-byte custom-sound block (CustomVoiceRecFetch
#          0x4844A42F).  The firmware reads the count's low byte (movbu +0x58 ...).
.macro CSTREC_DEPS offset, count
	.long	\offset, \count
.endm
#   +0x8C / +0x94 / +0x9C  {u32 offset, u32 size} of the one-touch-setting panel memories,
#          the "TCMP" style container (CustomStyleBlockFetch 0x48484578 -> func_48484305) and
#          the "TPAD" performance-pad container (func_48484332)
.macro CSTREC_SECTION offset, size
	.long	\offset, \size
.endm
#   +0xA4 / +0xA5  the record's first block and block count, as in its directory slot
.macro CSTREC_PLACE first, blocks
	.byte	\first, \blocks
.endm

# One {program, bank LSB, bank MSB} reference of the custom-sound block (+0x27 + i*3;
# CustomVoiceRecFetch re-resolves an absent voice through VoiceRecFetchBanked with it).
.macro VOICE_REF prog, bank_lsb, bank_msb
	.byte	\prog, \bank_lsb, \bank_msb
.endm

# ---- "TCMP" / "TPAD" N=1 containers (MemStyleExportToCustom 0x4843DEC7) -----------------
# The 0x70-byte header of the ROM templates 0x487312E8 / 0x48729858, with the checksum
# descriptor [0x06,0x10) left zero (the export clears it), the length +0x10 and the
# allocator top +0x13 both the container size, and one style / bank (+0x16).
.macro TCMP_HEADER size
	.ascii	"TCMP"
	.byte	0, 0
	.space	10
	.be24	\size, \size
	.be16	1
	.byte	0x00, 0x60, 0x0d, 0x08, 0x04, 0x02, 0x02, 0x01, 0x02, 0x0f
	.space	14
	.space	64, 0x20
.endm
.macro TPAD_HEADER size
	.ascii	"TPAD"
	.byte	0, 0
	.space	10
	.be24	\size, \size
	.be16	1
	.byte	0x00, 0x60, 0x10, 0x06, 0x10, 0x02, 0x00, 0x00, 0x00, 0x0f
	.space	14
	.space	64, 0x20
.endm

# The 0x80-byte style record at container +0x70 (CustStyleRecPtr 0x4843E107): the 13-byte
# name + 3 NUL, four 13-byte variation-name fields, the 20 variation indices 0..19
# (+0x50; CustStyleImportToMem renormalises them) and at +0x70 the style's two DSP-unit preset
# keys, a built-in style's `style_units` (+0x0D there): StyleNameCommitMem / StyleNameCommitCustom
# store record + 0x70 as the units pointer 0x50034C20, StyleDspUnitsApply 0x484420EF decodes it
# (StyleDspKeyDecode: {lo, hi} pairs, 7 bits a byte) into the keys of units EFF4 (0xB044) and EFF5
# (0xB054), bit 7 of byte +0x71 = TOTAL MODE (0xB001); func_4843A47C copies a built-in style's four
# bytes here.  The macro spells the four bytes as two u16BE words (units4 = +0x70/+0x71, units5 =
# +0x72/+0x73); most factory styles have 0x1000 0x2300, keys 0x0010 / 0x0023.
.macro TCMP_STYLE name, vname1, vname2, vname3, vname4, units4, units5
	.ascii	"\name"
	.ascii	"\vname1", "\vname2", "\vname3", "\vname4"
	.byte	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
	.space	12
	.be16	\units4, \units5
	.space	12
.endm

# The first 0x20 bytes of a 0xE0-byte variation record (CustStyleVarRecPtr 0x4843E10C:
# container +0xF0 + var*0xE0); eight PART_SETUP blocks follow.
#   src_lo    +0x00  \ the built-in style the variation was copied from: func_4843B386 (the
#   src_hi    +0x01   | copy of a built-in variation into a MEMORY style) writes key & 0x7F, key >> 7
#   src_ext   +0x02  /  and 0; func_4843511C reads them back as ((b1 << 8 | b0) & 0xF00) >> 1 | b0 & 0x7F
#                       for StyleBuiltinNameResolve.  0 0 0 in a variation written from scratch
#   flags     +0x03  bit 4 = the "B" half of a paired variation (MemStyleVarRecInit)
#   p0..p7    +0x04..+0x0B  one byte per part (MemStyleVarRecInit clamps them to 1 for
#             variations 12..19)
#   bars      +0x10  \ MemStyleVarBarCount 0x4843C445: the stream holds
#   meter     +0x11  /   (bars + 1) * ((meter & 7) + 1) beat markers
#   stream    +0x15  u24BE offset of the variation's event stream in the container
#   eff4, eff5 +0x18 / +0x19  the style parts the DSP units EFF4 / EFF5 apply to, 0xFF = the default
#             (Acc1 / Acc2): StyleRecordBindMem / StyleRecordBindCustom point 0x50122DD4 at +0x18, which
#             func_48442164 reads as a built-in variation's +2 / +3; func_4843B386 copies those there
.macro TCMP_VAR src_lo, src_hi, src_ext, flags, p0, p1, p2, p3, p4, p5, p6, p7, bars, meter, stream, eff4, eff5
	.byte	\src_lo, \src_hi, \src_ext, \flags
	.byte	\p0, \p1, \p2, \p3, \p4, \p5, \p6, \p7
	.space	4
	.byte	\bars, \meter
	.space	3
	.be24	\stream
	.byte	\eff4, \eff5
	.space	6
.endm

# A part's set-up, 24 bytes, one per field of the firmware's part-field table 0x485B77D4
# (24 {status, controller} pairs: B0 FF, CC7, the program change's 3 bytes, CC94, CC91,
# CC93, CC10, CC96, CC82, CC83, CC80, CC81, CC92, CC64, CC1, CC11, channel pressure, pitch
# bend's 2 bytes, CC16, CC17, CC13).  The first 15 are the built-in styles' 15-byte part
# set-up (src/ic18/rhythm.s, style_part).  Reader: StyleRecordBindMem / StyleRecordBindCustom
# put var + 0x20 + k * 0x18 in 0x50034BAC[k]; StyleTemplateLoadParts 0x4844187A copies 15 bytes
# of each into the part template 0x5003A37C, whose fields StylePartFieldEmit sends as table
# 0x485B77D4 says.  Bytes 15..23 are never read, and are 0 in every factory set-up
# (notes/custom-data-ic21-probes/tcmp_var_fields.py); their names follow the table.
.macro PART_SETUP mode, volume, prog, bank_lsb, bank_msb, cc94, reverb, chorus, pan, cc96, cc82, cc83, cc80, cc81, cc92, sustain, modulation, expression, pressure, bend_lsb, bend_msb, cc16, cc17, cc13
	.byte	\mode, \volume, \prog, \bank_lsb, \bank_msb, \cc94, \reverb, \chorus, \pan, \cc96, \cc82, \cc83
	.byte	\cc80, \cc81, \cc92, \sustain, \modulation, \expression, \pressure, \bend_lsb, \bend_msb, \cc16, \cc17, \cc13
.endm

# An event stream: the variation (or pad) index, the u24BE count of the event bytes that
# follow (MemStyleExportSize adds LoadU24BE(stream+1) + 4), then the events, from ev_beat
# to ev_end (MemStyleAreaStreamsVerify 0x4843579E).
.macro STREAM_HEADER index, count
	.byte	\index
	.be24	\count
.endm

# ---- events (RhyEventLenByStatus 0x484403D5, RhySysexLen 0x484403CD) --------------------
# The low nibble of a status byte is the part.
.macro ev_cc part, ctl, value
	.byte	0xb0 + \part, \ctl, \value
.endm
.macro ev_pc part, prog, bank_lsb, bank_msb
	.byte	0xc0 + \part, \prog, \bank_lsb, \bank_msb
.endm
# A note: key, velocity, then three bytes.  [INFERENCE] gate_lo/gate_hi a 14-bit length and
# `rule` the chord-adaptation class (src/ic18/rhythm.s).
.macro ev_note part, key, velocity, gate_lo, gate_hi, rule
	.byte	0x90 + \part, \key, \velocity, \gate_lo, \gate_hi, \rule
.endm
.macro ev_press part, value
	.byte	0xd0 + \part, \value
.endm
.macro ev_bend part, lsb, msb
	.byte	0xe0 + \part, \lsb, \msb
.endm
# A 4-byte SysEx, the only length these sets use (F0, the count, the bytes; RhySysexLen).
.macro ev_sysex4 d0, d1, d2, d3
	.byte	0xf0, 4, \d0, \d1, \d2, \d3
.endm
# A position byte: the tick in the beat (0-95, 96 a beat) of the events after it.
.macro ev_at tick
	.byte	\tick
.endm
.macro ev_beat
	.byte	0xf4
.endm
.macro ev_end
	.byte	0xf5
.endm

# The 0x30-byte bank record at TPAD +0x70: the bank name and its six pads, each
# {bank, pad, 0x20} (func_484384A3 builds the MEMORY ones with 0x10).
.macro TPAD_BANK name
	.ascii	"\name"
	.byte	0, 0, 0x20, 0, 1, 0x20, 0, 2, 0x20, 0, 3, 0x20, 0, 4, 0x20, 0, 5, 0x20
	.space	14
.endm

# The first 0x28 bytes of a 0x60-byte pad record (TPAD +0xA0 + pad*0x60; the MEMORY area's
# accessor is func_48438791): the 16-byte name, thirteen setting bytes, the u24BE stream offset
# (+0x1D, func_484387A9), eight zero bytes; two PART_SETUP blocks and eight zero bytes follow.
# The setting bytes the user-pad module reads (lane kn7000-research, 2026-11-06):
#   rec_chord +0x13  RECORD KEY / CHORD: bits 0-3 key, bit 4 minor (UserPadRecChordGet / Set)
#   bars      +0x18  \ measures - 1 and beats - 1 (MainPAD_SetUserPadMsrTmSigAftClr ->
#   meter     +0x19  /  func_4843264C stores them; func_484326B7 = (bars + 1) * ((meter & 7) + 1))
#   flags     +0x1A  bit 0 LOOP (UserPadLoopGet), bit 1 SYNCHRO (UserPadSynchroGet), bits 2/3 set
#                    for pads 4 and 5 by func_484385DD (PadFlag2ById reads bit 2)
#   s4, s5    +0x14 / +0x15  one per part; s0..s2, s6, s7, s11, s12: no reader in the pad module
.macro TPAD_PAD name, s0, s1, s2, rec_chord, s4, s5, s6, s7, bars, meter, flags, s11, s12, stream
	.ascii	"\name"
	.byte	\s0, \s1, \s2, \rec_chord, \s4, \s5, \s6, \s7, \bars, \meter, \flags, \s11, \s12
	.be24	\stream
	.space	8
.endm
