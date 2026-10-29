# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# voice_record.inc -- the KN7000's 0x8E-byte voice (sound) record, the unit of the tone
# generator's voice-resource banks, of the local-edit shadow and of a CUSTOM record's
# custom-sound block.  Layout from the program's sound-memory code (kn7000_manual.sym):
#   +0x00  16-byte header: the 13-byte name, then three bytes; +0x0D selects which of the
#          two sub-records applies (VoiceSubRecFetch 0x4844978B: 0xFF = no override)
#   +0x10  two 0x1C-byte sub-records (VoiceSubRecFetch: record +0x10 + n*0x1C)
#   +0x48  two 0x23-byte element records (TgPartLocalEditElemRecPtr 0x4C00C2F9: +0x48 +
#          elem*0x23; 0x10 + 2*0x1C + 2*0x23 = 0x8E)
# Field names are neutral (offset in the sub-record / element record): which byte means what
# is not traced yet (TgPartLocalEditRecBuild 0x4C00CABD.. builds the shadow from them).

.macro VOICE_HEAD name, h0d, h0e, h0f
	.ascii	\name
	.byte	\h0d, \h0e, \h0f
.endm
.macro VOICE_SUB s00, s01, s02, s03, s04, s05, s06, s07, s08, s09, s0a, s0b, s0c, s0d, s0e, s0f, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s1a, s1b
	.byte	\s00, \s01, \s02, \s03, \s04, \s05, \s06, \s07, \s08, \s09, \s0a, \s0b, \s0c, \s0d
	.byte	\s0e, \s0f, \s10, \s11, \s12, \s13, \s14, \s15, \s16, \s17, \s18, \s19, \s1a, \s1b
.endm
.macro VOICE_ELEM e00, e01, e02, e03, e04, e05, e06, e07, e08, e09, e0a, e0b, e0c, e0d, e0e, e0f, e10, e11, e12, e13, e14, e15, e16, e17, e18, e19, e1a, e1b, e1c, e1d, e1e, e1f, e20, e21, e22
	.byte	\e00, \e01, \e02, \e03, \e04, \e05, \e06, \e07, \e08, \e09, \e0a, \e0b, \e0c, \e0d, \e0e, \e0f, \e10, \e11
	.byte	\e12, \e13, \e14, \e15, \e16, \e17, \e18, \e19, \e1a, \e1b, \e1c, \e1d, \e1e, \e1f, \e20, \e21, \e22
.endm
