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

# ---- BEGIN SOUND EDIT (floppy-others lane, 2026-10-29) ----
# The 0x2C8-byte SOUND EDIT record: the KN6000 .TM files hold 40 (floppy/tools/kd/kn_soundram.py), a CUSTOM
# record its count of them (CustomSoundEditRecFetch 0x484845E1), RAM 0x500C0784 + (part-0x10)*0x2C8 one per aux part.
#   +0x00  0x54-byte header, the 16-character name first (TgPartAuxHdr45Get.. read +0x45..+0x47)
#   +0x54  four 0x7A-byte mod units (TgPartAuxModRecPtr 0x4C00C25B; TgPartAuxMod04Get reads +0x04)
#   +0x23C four 0x23-byte elements, VOICE_ELEM (TgPartAuxElemRecPtr 0x4C00C28D; 0x54 + 4*0x7A + 4*0x23 = 0x2C8)
# Names are offsets, as above.  The 16-character name is not a parameter: llvm-mc strips a quoted macro
# argument's quotes and kn7asm keeps them, so no `.ascii \name` spelling works for both assemblers.  The
# llvm-mc callers (the floppies) write `.ascii "<name>"` and then SOUND_HEAD; VOICE_HEAD_TAIL is VOICE_HEAD
# without its name, for the same reason.
.macro VOICE_HEAD_TAIL h0d, h0e, h0f
	.byte	\h0d, \h0e, \h0f
.endm
.macro SOUND_HEAD h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h1a, h1b, h1c, h1d, h1e, h1f, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h2a, h2b, h2c, h2d, h2e, h2f, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h3a, h3b, h3c, h3d, h3e, h3f, h40, h41, h42, h43, h44, h45, h46, h47, h48, h49, h4a, h4b, h4c, h4d, h4e, h4f, h50, h51, h52, h53
	.byte	\h10, \h11, \h12, \h13, \h14, \h15, \h16, \h17, \h18, \h19, \h1a, \h1b, \h1c, \h1d, \h1e, \h1f, \h20, \h21
	.byte	\h22, \h23, \h24, \h25, \h26, \h27, \h28, \h29, \h2a, \h2b, \h2c, \h2d, \h2e, \h2f, \h30, \h31, \h32, \h33
	.byte	\h34, \h35, \h36, \h37, \h38, \h39, \h3a, \h3b, \h3c, \h3d, \h3e, \h3f, \h40, \h41, \h42, \h43, \h44, \h45
	.byte	\h46, \h47, \h48, \h49, \h4a, \h4b, \h4c, \h4d, \h4e, \h4f, \h50, \h51, \h52, \h53
.endm
.macro SOUND_MOD m00, m01, m02, m03, m04, m05, m06, m07, m08, m09, m0a, m0b, m0c, m0d, m0e, m0f, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m1a, m1b, m1c, m1d, m1e, m1f, m20, m21, m22, m23, m24, m25, m26, m27, m28, m29, m2a, m2b, m2c, m2d, m2e, m2f, m30, m31, m32, m33, m34, m35, m36, m37, m38, m39, m3a, m3b, m3c, m3d, m3e, m3f, m40, m41, m42, m43, m44, m45, m46, m47, m48, m49, m4a, m4b, m4c, m4d, m4e, m4f, m50, m51, m52, m53, m54, m55, m56, m57, m58, m59, m5a, m5b, m5c, m5d, m5e, m5f, m60, m61, m62, m63, m64, m65, m66, m67, m68, m69, m6a, m6b, m6c, m6d, m6e, m6f, m70, m71, m72, m73, m74, m75, m76, m77, m78, m79
	.byte	\m00, \m01, \m02, \m03, \m04, \m05, \m06, \m07, \m08, \m09, \m0a, \m0b, \m0c, \m0d, \m0e, \m0f, \m10, \m11, \m12, \m13
	.byte	\m14, \m15, \m16, \m17, \m18, \m19, \m1a, \m1b, \m1c, \m1d, \m1e, \m1f, \m20, \m21, \m22, \m23, \m24, \m25, \m26, \m27
	.byte	\m28, \m29, \m2a, \m2b, \m2c, \m2d, \m2e, \m2f, \m30, \m31, \m32, \m33, \m34, \m35, \m36, \m37, \m38, \m39, \m3a, \m3b
	.byte	\m3c, \m3d, \m3e, \m3f, \m40, \m41, \m42, \m43, \m44, \m45, \m46, \m47, \m48, \m49, \m4a, \m4b, \m4c, \m4d, \m4e, \m4f
	.byte	\m50, \m51, \m52, \m53, \m54, \m55, \m56, \m57, \m58, \m59, \m5a, \m5b, \m5c, \m5d, \m5e, \m5f, \m60, \m61, \m62, \m63
	.byte	\m64, \m65, \m66, \m67, \m68, \m69, \m6a, \m6b, \m6c, \m6d, \m6e, \m6f, \m70, \m71, \m72, \m73, \m74, \m75, \m76, \m77
	.byte	\m78, \m79
.endm
# ---- END SOUND EDIT ----
