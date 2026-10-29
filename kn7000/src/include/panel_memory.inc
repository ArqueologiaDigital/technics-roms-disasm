# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# panel_memory.inc -- the KN7000 / KN6000 one-touch-setting panel memory: the compact record
# the library builds from four PANEL MEMORY records (0x750 bytes each on the KN7000, 0x700 on
# the KN6000) when a style is saved to CUSTOM.  Shared by the CUSTOM banks (src/customdata/)
# and, for the same record, the floppy describers.  Source: kn7000/notes/custom-data-ic21.md,
# section "One touch settings".
#
# The writer is KN7000 library func_4C02A0C4 (KN6000 func_4C04B9F8).  It copies fields out of
# panel-memory record i (0x84000834 + bank*0x3A90 + i*0x750 on the KN7000; 0x840007E2 +
# bank*0x3810 + i*0x700 on the KN6000) through tables of {source offset, destination offset,
# mask} triples: KN7000 program 0x4858E19C..0x4858E252, KN6000 0x4C19AB04.. (the same bytes).
# Every field is stored as source & mask; a parameter here is the stored byte, and its name is
# the SOURCE offset (p<hex> = offset in a part record, q/r/t/f/g/h<hex> = offset in the panel
# record's section named in each macro), so these names are the panel-memory record's own.
# Fields whose meaning is traced carry a real name.

# One part's settings, 26 bytes (triple table 0x4858E19C).  Source: the part record at panel
# record +0x16 + part*0x4A (parts 0..2) or +0x2E0 (KN7000) / +0x296 (KN6000) (part 3).
#   voice_prog, voice_bank_lsb, voice_bank_msb   the part's sound as {program, bank LSB, bank
#   MSB}: func_4C02B2FE classifies the triple and the writer replaces it with the CUSTOM copy's
#   reference when it names a user sound (class 1) or user kit (class 2)
#   voice_prog       part +0x00, mask 0x7f
#   voice_bank_lsb   part +0x01, mask 0x7f
#   voice_bank_msb   part +0x02, mask 0x7f
#   p03              part +0x03, mask 0xff
#   p04              part +0x04, mask 0xdf
#   p06              part +0x06, mask 0x03
#   p0b              part +0x0b, mask 0xff
#   p0c              part +0x0c, mask 0xff
#   p0d              part +0x0d, mask 0xff
#   p0e              part +0x0e, mask 0x7f
#   p0f              part +0x0f, mask 0xff
#   p18              part +0x18, mask 0x7f
#   p19              part +0x19, mask 0x7f
#   p1a              part +0x1a, mask 0x7f
#   p1b              part +0x1b, mask 0x7f
#   p1c              part +0x1c, mask 0x7f
#   p1d              part +0x1d, mask 0x7f
#   p1e              part +0x1e, mask 0xff
#   p22              part +0x22, mask 0x0f
#   p24              part +0x24, mask 0xff
#   p25              part +0x25, mask 0xff
#   p26              part +0x26, mask 0xff
#   p27              part +0x27, mask 0xff
#   p28              part +0x28, mask 0xff
#   p29              part +0x29, mask 0xff
#   p2a              part +0x2a, mask 0x3f
.macro PM_PART voice_prog, voice_bank_lsb, voice_bank_msb, p03, p04, p06, p0b, p0c, p0d, p0e, p0f, p18, p19, p1a, p1b, p1c, p1d, p1e, p22, p24, p25, p26, p27, p28, p29, p2a
	.byte	\voice_prog, \voice_bank_lsb, \voice_bank_msb, \p03, \p04, \p06, \p0b, \p0c, \p0d, \p0e, \p0f, \p18, \p19
	.byte	\p1a, \p1b, \p1c, \p1d, \p1e, \p22, \p24, \p25, \p26, \p27, \p28, \p29, \p2a
.endm

# Eight bytes, one from each of the panel record's 6-byte entries at +0xF4 + i*6 (table
# 0x4858E1EA: entry +0, mask 0xFF).
.macro PM_ENTRIES q0f4, q0fa, q100, q106, q10c, q112, q118, q11e
	.byte	\q0f4, \q0fa, \q100, \q106, \q10c, \q112, \q118, \q11e
.endm

# +0x70..+0x76 (table 0x4858E1ED, source panel record +0x6B6 KN7000 / +0x66C KN6000):
#   slot   the CUSTOM style the setting belongs to: the writer stores func_4843E452(slot) =
#          slot | 0x200000 as three bytes, low first, over the first three fields
#   r4     source +4, mask 0x40
#   ots    which of the four settings (0..3): bits 4-5 of the byte (source +7, mask 0x30, then
#          replaced by the writer's running 0x00 / 0x10 / 0x20 / 0x30)
#   r8     source +8          r9   source +9, mask 0x01
.macro PM_STYLE slot, r4, ots, r8, r9
	.byte	\slot, 0x00, 0x20, \r4, (\ots) * 16, \r8, \r9
.endm
# +0x77..+0x79 (table 0x4858E202, source +0x6C6 / +0x67C): t0 mask 0x07, t3 mask 0x01, t4.
.macro PM_SET77 t0, t3, t4
	.byte	\t0, \t3, \t4
.endm
# +0x7A..+0x87 (table 0x4858E20B, source +0x6D0 / +0x686): f00 mask 0x88, then f01..f07 and
# f0e..f13, mask 0x7F.  The six byte pairs f02/f03, f04/f05, f06/f07, f0e/f0f, f10/f11, f12/f13
# are 14-bit ids that the writer re-maps through func_48413686 (kinds 0, 9, 1, 2, 3, 4) when
# they name user data, so it stores the CUSTOM copy's id.  [INFERENCE] effect / DSP ids.
.macro PM_FX f00, f01, f02, f03, f04, f05, f06, f07, f0e, f0f, f10, f11, f12, f13
	.byte	\f00, \f01, \f02, \f03, \f04, \f05, \f06, \f07, \f0e, \f0f, \f10, \f11, \f12, \f13
.endm
# +0x88..+0x8B (table 0x4858E235, source +0x700 / +0x6B6): g00 mask 0x04, g03, g04 mask 0x0F, g08.
.macro PM_SET88 g00, g03, g04, g08
	.byte	\g00, \g03, \g04, \g08
.endm
# +0x8C..+0x8D (table 0x4858E241, source +0x716 / +0x6C6): h00, h01; h01 is then passed through
# func_484417B9 (KN6000 func_4C063396).
.macro PM_SET8C h00, h01
	.byte	\h00, \h01
.endm
# KN7000 only, +0x8F..+0x9A: three more bytes of each of the four parts (table 0x4858E24A):
# part +0x23 mask 0x07, +0x38, +0x39.
.macro PM_PART_TAIL p23, p38, p39
	.byte	\p23, \p38, \p39
.endm

# ---- BEGIN PMR (generated by floppy/tools/kd/gen_panel_macros.py; do not edit by hand) ----
# The full PANEL MEMORY record: the floppies' .PMT memories and .LSW panels hold it as is, and its
# byte offsets are the "source" offsets of the triple tables above: the 72-byte part records start at
# record +0x16 + part*0x4A (tag 0x10 at +0x14), the eight 4-byte entries at +0xF4 + i*6 (tags 0x13-0x1A).
# Order and tags: floppy/tools/kd/kn_panel.py.  [INFERENCE] beyond the fields named in PM_PART: the
# record's reader is not traced; the names are offsets.
.macro PMR_END
	.byte	0xff, 0xff
.endm
# 0x40, 18 bytes: the memory's 16-character name, then n10, n11.  The name is not a parameter (llvm-mc
# strips a quoted argument's quotes, kn7asm keeps them): PMR_NAME_HEAD, then .ascii "<name>", then
# PMR_NAME_TAIL.
.macro PMR_NAME_HEAD
	.byte	0x40, 18
.endm
.macro PMR_NAME_TAIL n10, n11
	.byte	\n10, \n11
.endm
# A part record, 72 bytes: tags 0x00-0x0F, 0x10-0x12, 0x1B, 0x1C and (KN7000) 0x1F.
.macro PMR_PART tag, voice_prog, voice_bank_lsb, voice_bank_msb, p03, p04, p05, p06, p07, p08, p09, p0a, p0b, p0c, p0d, p0e, p0f, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p1a, p1b, p1c, p1d, p1e, p1f, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p2a, p2b, p2c, p2d, p2e, p2f, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p3a, p3b, p3c, p3d, p3e, p3f, p40, p41, p42, p43, p44, p45, p46, p47
	.byte	\tag, 72
	.byte	\voice_prog, \voice_bank_lsb, \voice_bank_msb, \p03, \p04, \p05, \p06, \p07, \p08, \p09, \p0a, \p0b, \p0c, \p0d, \p0e, \p0f, \p10, \p11
	.byte	\p12, \p13, \p14, \p15, \p16, \p17, \p18, \p19, \p1a, \p1b, \p1c, \p1d, \p1e, \p1f, \p20, \p21, \p22, \p23
	.byte	\p24, \p25, \p26, \p27, \p28, \p29, \p2a, \p2b, \p2c, \p2d, \p2e, \p2f, \p30, \p31, \p32, \p33, \p34, \p35
	.byte	\p36, \p37, \p38, \p39, \p3a, \p3b, \p3c, \p3d, \p3e, \p3f, \p40, \p41, \p42, \p43, \p44, \p45, \p46, \p47
.endm
# A 4-byte entry, tags 0x13-0x1A (PM_ENTRIES stores byte e0 of each).
.macro PMR_ENTRY tag, e0, e1, e2, e3
	.byte	\tag, 4, \e0, \e1, \e2, \e3
.endm
.macro PMR_41_8 x00, x01, x02, x03, x04, x05, x06, x07
	.byte	0x41, 8
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07
.endm
.macro PMR_42_14 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d
	.byte	0x42, 14
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d
.endm
.macro PMR_43_2 x00, x01
	.byte	0x43, 2
	.byte	\x00, \x01
.endm
.macro PMR_44_14 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d
	.byte	0x44, 14
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d
.endm
.macro PMR_44_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x44, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_45_2 x00, x01
	.byte	0x45, 2
	.byte	\x00, \x01
.endm
.macro PMR_46_4 x00, x01, x02, x03
	.byte	0x46, 4
	.byte	\x00, \x01, \x02, \x03
.endm
.macro PMR_47_14 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d
	.byte	0x47, 14
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d
.endm
.macro PMR_48_30 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x1a, x1b, x1c, x1d
	.byte	0x48, 30
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15, \x16, \x17, \x18, \x19, \x1a, \x1b, \x1c, \x1d
.endm
.macro PMR_4A_4 x00, x01, x02, x03
	.byte	0x4a, 4
	.byte	\x00, \x01, \x02, \x03
.endm
.macro PMR_4B_8 x00, x01, x02, x03, x04, x05, x06, x07
	.byte	0x4b, 8
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07
.endm
.macro PMR_4C_30 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x1a, x1b, x1c, x1d
	.byte	0x4c, 30
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15, \x16, \x17, \x18, \x19, \x1a, \x1b, \x1c, \x1d
.endm
.macro PMR_4D_14 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d
	.byte	0x4d, 14
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d
.endm
.macro PMR_50_8 x00, x01, x02, x03, x04, x05, x06, x07
	.byte	0x50, 8
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07
.endm
.macro PMR_51_14 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d
	.byte	0x51, 14
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d
.endm
.macro PMR_52_40 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x1a, x1b, x1c, x1d, x1e, x1f, x20, x21, x22, x23, x24, x25, x26, x27
	.byte	0x52, 40
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15, \x16, \x17, \x18, \x19, \x1a, \x1b, \x1c, \x1d, \x1e, \x1f, \x20, \x21, \x22, \x23
	.byte	\x24, \x25, \x26, \x27
.endm
.macro PMR_52_46 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x1a, x1b, x1c, x1d, x1e, x1f, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x2a, x2b, x2c, x2d
	.byte	0x52, 46
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15, \x16, \x17, \x18, \x19, \x1a, \x1b, \x1c, \x1d, \x1e, \x1f, \x20, \x21, \x22, \x23
	.byte	\x24, \x25, \x26, \x27, \x28, \x29, \x2a, \x2b, \x2c, \x2d
.endm
.macro PMR_60_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x60, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_60_22 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15
	.byte	0x60, 22
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15
.endm
.macro PMR_61_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x61, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_61_22 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15
	.byte	0x61, 22
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15
.endm
.macro PMR_62_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x62, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_62_22 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15
	.byte	0x62, 22
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15
.endm
.macro PMR_68_16 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f
	.byte	0x68, 16
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f
.endm
# ---- END PMR ----
