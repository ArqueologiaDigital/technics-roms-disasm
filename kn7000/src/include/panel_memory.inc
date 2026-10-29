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
