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
