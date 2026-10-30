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
