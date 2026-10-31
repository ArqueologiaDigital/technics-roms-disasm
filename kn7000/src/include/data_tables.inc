# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# data_tables.inc -- the program data region's lookup tables (tools/gen_data_s.py, reader_tables):
# a table whose reader loads one element width, written in that width and signedness, and a sparse
# map (a table that mostly holds the all-ones "none" value) written entry by entry with its index.
# Each table's header comment names its size, range and the instruction that reads it.
.macro tab_u8 v:vararg
	.byte	\v
.endm
.macro tab_s8 v:vararg
	.byte	\v
.endm
.macro tab_u16 v:vararg
	.word	\v
.endm
.macro tab_s16 v:vararg
	.word	\v
.endm
.macro tab_u32 v:vararg
	.long	\v
.endm
.macro tab_s32 v:vararg
	.long	\v
.endm
# A sparse map: entry `index` (documentation: it is the entry's position) holds `value`; mapN_none
# n = n entries with no value (all ones).
.macro map8 index, value
	.byte	\value
.endm
.macro map16 index, value
	.word	\value
.endm
.macro map_none8 n
	.space	\n, 0xFF
.endm
.macro map_none16 n
	.space	2 * \n, 0xFF
.endm
# A multiplicative hash table (the SX-KN6000's built-in sound tables; the KN7000 'JK' archive's are the
# same, with offsets): a descriptor {u16 mult, u16 nbuckets}, then nbuckets bucket pointers, each the
# head of a chain of entries {u32 next, key, payload}; an entry with key k is in bucket
# k * mult % nbuckets.  hash_desc: the descriptor; hash_ent32 / hash_ent16: an entry's link and key
# (the payload follows as its own lines).
.macro hash_desc mult, nbuckets
	.word	\mult, \nbuckets
.endm
.macro hash_ent32 next, key
	.long	\next
	.long	\key
.endm
.macro hash_ent16 next, key
	.long	\next
	.word	\key
.endm
# One entry of the SupportClass table (registry slot 0xD, tools/gen_data_s.py support_classes):
# SupportClassProc (0x4842AAF0) indexes it by an id's low half, 12 bytes an entry: MT_GetInstance
# answers the entry's address, MT_GetPropSize its +6 halfword, any other message is passed to the
# entry's +0 procedure (`mov (d1, a0), a1 / calls (a1)`).  +4 and +8 are not read there (`x4`, `data`).
.macro SUPPORT_CLASS proc, x4, propsize, data
	.long	\proc
	.word	\x4, \propsize
	.long	\data
.endm
# One entry of a table of the resource-id trie (tools/gen_data_s.py resource_trie): func_4C01BB1A
# (lib 0x4C01BB1A) indexes a table by one nibble of the id; `target` is the leaf record (inner 0) or
# the next table, of `count` entries (inner 1); target 0: no such id.
.macro RES_TRIE_ENTRY target, inner, count
	.long	\target
	.byte	\inner, \count
	.word	0
.endm
# One entry of the KN7000's alphabetical sound lists (tools/gen_data_s.py sound_alpha_lists, lane
# mn10300-formats): the sound's initial and the MIDI bank select / program change that select it.
# SoundAlphaIndexBuild (941 0x485831DC) groups the entries by `initial` (letters first, then digits:
# the C library's ctype table, bits 0x03 and 0x04) into its index at 0x5009E732; SoundAlphaInitialGet
# (0x485834C0) finds the entry whose msb / lsb / program match a sound and answers its initial.
# A list ends with an entry whose initial is 0.
.macro SOUND_ALPHA initial, msb, lsb, program
	.ascii	"\initial"
	.byte	\msb, \lsb, \program
.endm
# The payloads of the SX-KN6000's three sound hash tables (tools/gen_data_s.py hash_tables, lane
# mn10300-formats; kn7000/notes/mn10300-formats/README.md).  The bytes no routine reads are 0 in every
# entry (notes/mn10300-formats-probes/hash_payloads.py), written as the trailing .space.
# ToneKeyHash (key bank MSB << 16 | LSB << 8 | program): SoundToneIndexGet (0x4C09B065) answers `tone` (the tone
# record's index; func_4C07BA76 names the sound from it), SoundIconGet (0x4C09B03B) answers `icon` (MainGetSoundName,
# MT_GetSoundIcon), SoundSwNoGet (0x4C09AFB0) answers the sound's panel switch {group, number} for the reference's
# state 0..3: {swgroup01, swno0}, {swgroup01, swno1}, {swgroup23, swno2}, {swgroup23, swno3}
# (MainGetSoundName, MT_GetSoundSwNo).
.macro TONE_KEY_PAYLOAD tone=0, icon=0, swgroup01=0, swgroup23=0, swno0=0, swno1=0, swno2=0, swno3=0
	.word	\tone
	.byte	\icon, \swgroup01, \swgroup23, \swno0, \swno1, \swno2, \swno3
	.space	3, 0x00
.endm
# ShortKeyHash (key: a panel switch, group << 8 | number, SoundSwNoBankGet 0x4C09B200): the bank MSB, LSB and program
# change that switch selects (SoundSwNoBankGet copies +0, +1, +2 to its three outputs).
.macro SHORT_KEY_PAYLOAD msb=0, lsb=0, program=0
	.byte	\msb, \lsb, \program
	.space	3, 0x00
.endm
# BankKeyHash (key bank MSB << 16 | LSB << 8 | program): SoundBankIndexGet (0x4C09BCFA) copies the u16 `index` (`movhu
# (a0), d0`) to its output.
.macro BANK_KEY_PAYLOAD index=0
	.word	\index
	.space	2, 0x00
.endm
# The SX-KN2400's DSP-effect descriptors (tools/gen_data_s.py fx_descriptors, lane mn10300-formats; the
# routines are kn2400_manual.sym's Fx*, the probe notes/mn10300-formats-probes/kn2400_fx_desc.py).
# FX_DESC: FxDescGet's 16-byte record: `count` FX_PARAM records at `params` (right before it), `nparams`
# parameter numbers (FxDescNParamsGet), `mode` (FxDescModeGet; SndUnitDbGroupQuery searches the
# parameters for 1 and 2), pnum9 / pnum10 / pnum11 (a parameter number or -1; roles not traced) and
# `send_param`, the REVERB SEND parameter's number (-1 in the reverbs).
.macro FX_DESC params, count=0, nparams=0, mode=0, pnum9=-1, pnum10=-1, pnum11=-1, send_param=-1
	.byte	\count, \nparams
	.word	0
	.long	\params
	.byte	\mode, \pnum9, \pnum10, \pnum11, \send_param
	.space	3, 0x00
.endm
# FX_PARAM: one 36-byte parameter record (FxParamGet): its name, NUL-padded to 20 bytes (`pad` NULs
# after the text), parameter number (FxParamNumberGet), minimum and maximum (FxParamMinGet /
# FxParamMaxGet), EQ band and sub-parameter (FxParamBandGet / FxParamSubGet), `variant` (0 / 1: two
# alternative records of one number, 0xFF: always; FxParamVariantGet), x29 (FxParamX29Get) and the
# value texts (FxParamValuesGet).
.macro FX_PARAM name, pad, number=0, min=0, max=0, band=0xFF, sub=0, variant=0xFF, x29=0xFF, values=0
	.ascii	"\name"
	.space	\pad, 0x00
	.word	\number, \min, \max
	.byte	\band, \sub, \variant, \x29
	.word	0
	.long	\values
.endm
