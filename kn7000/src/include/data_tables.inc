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
# One entry of the SupportClass table (registry slot 0xD; 0x1C0 in the KN6000 / KN6500 layout;
# tools/gen_data_s.py support_classes): SupportClassProc (941 0x4842AAF0) indexes it by an id's low
# half, 12 bytes an entry: MT_GetInstance answers the entry's address, MT_GetPropSize its +6
# halfword, any other message is passed to the entry's +0 procedure (`mov (d1, a0), a1 / calls
# (a1)`).  The procedures pass what they do not answer to the classes' common handler (941
# func_48431434, a3 = the entry), which reads +4 and +8: `movhu (4, a3), d0` / `cmp 0, d0` / `beq`
# (no names), then `mov (8, a3)` the value-name list (SPT_VALUE_NAME below).
.macro SUPPORT_CLASS proc, nnames, propsize, value_names
	.long	\proc
	.word	\nnames, \propsize
	.long	\value_names
.endm
# One pair of a support class's value-name list (SUPPORT_CLASS value_names): the handler turns a
# value into its name (`mov (4, a0), d0` / `cmp d3, d0` / `strcpy`), a name into its value (`strcmp`,
# then `mov (4, a0), d0`; -1 when none matches) and gives the n-th name (`asl 3` / `mov (d0, a1)`);
# every walk stops at the pair whose name's first byte is 0 (`movbu (a0), d0` / `cmp 0, d0`).
.macro SPT_VALUE_NAME name, value
	.long	\name
	.long	\value
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
# record's index; SoundNameGet 0x4C07BA76 names the sound from it), SoundIconGet (0x4C09B03B) answers `icon`
# (MainGetSoundName, MT_GetSoundIcon), SoundSwNoGet (0x4C09AFB0) the sound's switch {group, number} for the switch
# state (lane mn10300-rest, kn7000/notes/mn10300-rest/README.md): 0 {panel_group, panel_no_dsp}, 1 {panel_group,
# panel_no}, 2 {explorer_group, explorer_no_dsp}, 3 {explorer_group, explorer_no}.  The panel states are the SOUND
# GROUP buttons (group 0..15, MT_GetSoundSwNo), the explorer ones the 32 SOUND EXPLORER categories (GetSoundDev);
# the even state is for a part that has a DSP unit (PartHasDspUnit 0x4C007A5B), the odd one for a part that has none.
.macro TONE_KEY_PAYLOAD tone=0, icon=0, panel_group=0, explorer_group=0, panel_no_dsp=0, panel_no=0, explorer_no_dsp=0, explorer_no=0
	.word	\tone
	.byte	\icon, \panel_group, \explorer_group, \panel_no_dsp, \panel_no, \explorer_no_dsp, \explorer_no
	.space	3, 0x00
.endm
# ShortKeyHash (key: a switch, key group << 8 | number, SoundSwNoBankGet 0x4C09B200; the key group is the group + 0,
# 0x10, 0x40 or 0x60 by the switch state): the bank MSB, LSB and program change that switch selects
# (SoundSwNoBankGet copies +0, +1, +2 to its three outputs).
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
# parameter numbers (FxDescNParamsGet), `connection` (FxDescModeGet; FxConnectionGet 0x4863BA0B maps it to the
# unit's connection message, kind 9; SndUnitDbGroupQuery and FxDepthApply act for 1 and 2: 0 the reverbs,
# choruses and gates, 1 the depth effects, 2 rotary / amp / wah / pitch, 3 Dry/Wet [INFERENCE: a connection
# type]), three parameter numbers or -1 (lane mn10300-rest, probe notes/mn10300-rest-probes/kn2400_fx_pnums.py):
# `speed_param` (FxDescPnum9Get; FxSpeedNudge 0x4863B51E moves that parameter by a value - 0x40, clamped:
# LFO SPEED, SLOW LFO SPEED or PEDAL in the 27 descriptors that set it), `tempo_param` (FxDescPnum10Get;
# FxParamValueGet 0x4863DF3E answers GetM3Em id 4, the TEMPO, for it: the two "TEMPO" effects), `drive_param`
# (FxDescPnum11Get; func_4863B2B6 / func_4863B3CF test it for -1 before reloading an effect of the same
# type: the DRIVE of the 9 rotary / amp twins), and `send_param`, the REVERB SEND parameter's number (-1 in
# the reverbs).
.macro FX_DESC params, count=0, nparams=0, connection=0, speed_param=-1, tempo_param=-1, drive_param=-1, send_param=-1
	.byte	\count, \nparams
	.word	0
	.long	\params
	.byte	\connection, \speed_param, \tempo_param, \drive_param, \send_param
	.space	3, 0x00
.endm
# FX_PARAM: one 36-byte parameter record (FxParamGet): its name, NUL-padded to 20 bytes (`pad` NULs
# after the text), parameter number (FxParamNumberGet), minimum and maximum (FxParamMinGet /
# FxParamMaxGet), EQ band and sub-parameter (FxParamBandGet / FxParamSubGet), `variant` (0 / 1: two
# alternative records of one number, 0xFF: always; FxParamVariantGet), `depth_link` (0: the parameter
# follows the panel's depth control, 0xFF: it does not; FxParamNextDepthLinked 0x4863D5E0 finds the next
# such record, FxDepthApply 0x4863BA75 scales it by the control / 0x50; lane mn10300-rest) and the
# value texts (FxParamValuesGet).
.macro FX_PARAM name, pad, number=0, min=0, max=0, band=0xFF, sub=0, variant=0xFF, depth_link=0xFF, values=0
	.ascii	"\name"
	.space	\pad, 0x00
	.word	\number, \min, \max
	.byte	\band, \sub, \variant, \depth_link
	.word	0
	.long	\values
.endm
# The SX-KN2400's effect-DSP streams (tools/gen_data_s.py fx_streams, lane mn10300-rest; the routines are
# kn2400_manual.sym's FxDsp* / FxParam*, the probe kn7000/notes/mn10300-rest-probes/kn2400_fx_streams.py).
# A program stream (FxDspStreamExec 0x5018A345) is records of one kind byte and a 12-bit length that counts the
# whole record: 0xFB n raw bytes, 0xFC n 4-byte program words (word i to step FxUnitProgramBase[unit] + i),
# 0xFD / 0xF7 n big-endian u24 coefficients from address `start` (0xFD as one burst, 0xF7 each after
# register 0xFF = its address), 0xFE {u16 register, u24 value} pairs up to the next kind byte, 0xFF the end.
.macro FXP_RAW n
	.byte	0xfb, ((\n + 3) >> 8) & 0x0f, (\n + 3) & 0xff
.endm
.macro FXP_STEPS n
	.byte	0xfc, ((4 * \n + 3) >> 8) & 0x0f, (4 * \n + 3) & 0xff
.endm
.macro FXP_COEF start, n
	.byte	0xfd, ((3 * \n + 5) >> 8) & 0x0f, (3 * \n + 5) & 0xff, (\start >> 8) & 0xff, \start & 0xff
.endm
.macro FXP_COEF_EACH start, n
	.byte	0xf7, ((3 * \n + 5) >> 8) & 0x0f, (3 * \n + 5) & 0xff, (\start >> 8) & 0xff, \start & 0xff
.endm
.macro FXP_U24 v
	.byte	(\v >> 16) & 0xff, (\v >> 8) & 0xff, \v & 0xff
.endm
.macro FXP_U24x4 a, b, c, d
	FXP_U24	\a
	FXP_U24	\b
	FXP_U24	\c
	FXP_U24	\d
.endm
.macro FXP_REGS
	.byte	0xfe
.endm
.macro FXP_REG reg, value
	.byte	(\reg >> 8) & 0xff, \reg & 0xff
	FXP_U24	\value
.endm
.macro FXP_END
	.byte	0xff
.endm
# A parameter script (FxParamScriptRun 0x5018A724, FxScriptGroupFind, FxParamEntryExec 0x5018A7B8): a group per
# parameter number, `len` the group's bytes with the length itself (big-endian), entries {kind, index into the
# kind's address-map group, operands} and FXS_NEXT (0x7A) after each run, FXS_END (0xFF) after the last group.
# The operand bytes per kind are each converter's (gen_data_s.FX_OPS); FXS_OP6 is two u24 operands (kinds 0x21 /
# 0x64 / 0x66: lo, hi; 0x6B / 0x6C / 0x73 the same byte count [INFERENCE: the same layout]), FXS_OP3 one.
.macro FXS_GROUP len
	.byte	(\len >> 8) & 0xff, \len & 0xff
.endm
.macro FXS_OP kind, index
	.byte	\kind, \index
.endm
.macro FXS_OP3 kind, index, v
	.byte	\kind, \index
	FXP_U24	\v
.endm
.macro FXS_OP6 kind, index, lo, hi
	.byte	\kind, \index
	FXP_U24	\lo
	FXP_U24	\hi
.endm
.macro FXS_NEXT
	.byte	0x7a
.endm
.macro FXS_END
	.byte	0xff
.endm
# An address map (FxMapAddrFind 0x5018AE27): groups {u16 BE len, kind, u16 BE DSP addresses}, 0xFF after the last.
.macro FXM_GROUP len, kind
	.byte	(\len >> 8) & 0xff, \len & 0xff, \kind
.endm
.macro FXM_END
	.byte	0xff
.endm
.macro FXM_ADDR a
	.byte	(\a >> 8) & 0xff, \a & 0xff
.endm
.macro FXM_ADDR4 a, b, c, d
	FXM_ADDR	\a
	FXM_ADDR	\b
	FXM_ADDR	\c
	FXM_ADDR	\d
.endm
# The first 32 bytes of a FAT boot sector (tools/gen_data_s.py boot_sectors): the jump to the boot
# code, the OEM name and the DOS 3 BIOS parameter block, at the offsets of Microsoft's "FAT: General
# Overview of On-Disk Format" (+0x0B bytes a sector ... +0x1C hidden sectors, u16 little-endian).  The
# disk formatters copy one into a zeroed sector (941 func_484707AC / func_48470A76: memcpy(.., 0x20)).
.macro FAT_BOOT_HEAD jmp0, jmp1, jmp2, oem, bytes_per_sector, sectors_per_cluster, reserved_sectors, fat_count, root_entries, total_sectors, media, sectors_per_fat, sectors_per_track, heads, hidden_sectors
	.byte	\jmp0, \jmp1, \jmp2
	.ascii	"\oem"
	.word	\bytes_per_sector
	.byte	\sectors_per_cluster
	.word	\reserved_sectors
	.byte	\fat_count
	.word	\root_entries, \total_sectors
	.byte	\media
	.word	\sectors_per_fat, \sectors_per_track, \heads, \hidden_sectors
.endm
