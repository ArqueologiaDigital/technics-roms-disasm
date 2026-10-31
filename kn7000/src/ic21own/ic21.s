# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Technics SX-KN7000 IC21, the 2 MB custom-data flash (CPU 0x96800000-0x969FFFFF), as read from
# Felipe's own instrument: byte-exact, every region typed.
#
# WHERE THE READ COMES FROM.  Pass 1 of the ROM dumper on Felipe's KN7000 (PROGRAM 893, TABLE 80),
# 2026-10-19, read twice with identical results (SHA-1 33b988ec7f63e5fe3c8299f1db2e3b5955a71ff2).
# The read is private: kn7000/Makefile copies it to baserom/kn7000_ic21_own.bin (git-ignored, SHA-1
# checked) and `make -C kn7000 verify-ic21-own` rebuilds it from this source.  The owner decided on
# 2026-10-31 that it becomes typed source in this repository.
#
# WHAT THE CHIP HOLDS (chip offsets; figures printed by kn7000/notes/ic21-own-probes/, `make -C kn7000
# ic21-own-probes`; routine addresses are program 941's, kn7000/src/program/):
#
#   0x00000-0x03FFF  erased.
#   0x04000-0x04AA3  the USER MIDI SETTING image (0xAA4 bytes; RAM copy 0x500D2B14, func_4C024247):
#     0x04000-0x0427F  the .MD part: all 640 bytes equal 02UMDINI.MD on the Initial Data Disk, and the
#                      default the firmware writes itself (program 893 0x486162A0).  Three USER MIDI
#                      SETTINGs over 44 parameters: LOCAL, MIDI CHANNEL and MIDI OCTAVE per part, the
#                      CONTROL channel, the MIDI message filters, split mode and point.
#     0x04280-0x04A6F  a 2,032-byte image of the live panel state (0x84000020), stored and recalled by
#                      func_4C021903: a PANEL MEMORY record of 43 tag/length records and a second list
#                      of 7.  1,935 of its bytes equal the firmware's default (Str_empty_1431): this
#                      unit's settings.
#     0x04A70-0x04AA3  26 halfwords of system settings (language, display times, data protect, ...);
#                      42 of the 52 bytes equal the default the boot check writes.
#   0x04AA4-0x05FFF  erased.
#   0x06000-0x07FFF  A5 A5 5A 5A fill: the pattern the ROM test's flash test writes itself
#                    (func_4849FCF2; the constant at 941 0x4849FD19 / 893 0x4849FB0C, the address
#                    0x96806000 at 941 0x4849FD35 / 893 0x4849FB28).  So that test has run on this unit.
#   0x08000-0x0FFFF  erased.
#   0x10000-0x10197  FAVORITES: all 408 bytes equal 03FAVINI.FAV, and the firmware's default (program
#                    893 0x48604390).
#   0x10198-0x10FFF  erased.
#   0x11000-0x15441  HOME PAGE: the 396-byte record equals the one of 04HPGINI.HMP except 53 bytes, in
#                    one run at +0x08..+0x53 (the home-page type and its parts: this unit's home page);
#                    the 17,078-byte BMP after it equals 04HPGINI.HMP's and program 893's default picture.
#   0x15442-0x1FFFF  erased.
#   0x20000-0x1FFFFF the CUSTOM STYLE bank (the factory banks' format, kn7000/notes/custom-data-ic21.md):
#                    20 styles with their ONE TOUCH SETTING panel memories in blocks 1-21, then residue of
#                    earlier writes in free blocks 22 and 24-27; used up to 0xF8F16, erased after.  Only
#                    969 of its 3,472 256-byte chunks (27.9%) occur in any of the nine factory banks, and
#                    none of its used 64 KB sectors equals one of theirs.
#
# THE CUSTOM STYLES ARE KN5000 STYLES.  Of the 340 name fields of the 20 records (style, one touch
# settings, the TCMP style and variation names, the pad bank and pads), 208 are KN5000 program names
# (116 distinct, e.g. "16Bt Soul", "BigBand Slow1", "40's Dance Band", "Harry J.& Co") and 127 standard
# KN7000 names every custom set carries (18 distinct: intros, endings, "Voice Drum 1" ...); none is a
# name of the nine factory KN7000 sets.  Five are not found as they are: "Jazz At 3.00am" is the
# KN5000's "Jazz At 3:00am", and "3/4 Played By 4", "Disco - Techni" and "Sentimntal Solo" are its
# "3/4 Played by 4", "Disco-Techni" and "Sentimental Solo" respelled; "Metallic Dance" matches no image
# this repository reads (name_fields.py).  So someone loaded KN5000 styles into this unit; besides
# those five, no name of anyone's own typing was found.  (A plain text-run search, names_kn5000.py,
# finds 39 KN5000 and 17 KN7000 names.)  The owner's manual (p.120) says CUSTOM holds 20 styles copied
# from COMPOSER MEMORY; the Initial Data Disk resets it to the factory set (p.137).
#
# [INFERENCE] The region boundaries fit the sector map of a bottom-boot 16 Mbit AMD flash (16 KB,
# 8 KB, 8 KB, 32 KB, then 64 KB sectors; src/symbols.inc names the command window CUSTOM_FLASH_CMD,
# "AMD 29LV160"): each block above starts a sector of its own.
#
# Formats and evidence: kn7000/notes/ic21-own/README.md; macros: src/include/user_settings.inc (the
# blocks below 0x20000), src/customdata/customdata.inc, src/include/panel_memory.inc and
# src/include/voice_record.inc.  midi.inc, favorites.inc, homepage.inc (tools/gen_ic21own_s.py) and
# custom.s with custom/ (tools/gen_customdata_s.py --base 0x20000 --part) are generated:
# `make -C kn7000 ic21-own-src`.  Labels are CPU addresses (.mnbase); .org and .incbin_range take
# chip offsets.

.mnbase 0x96800000
.include "src/include/user_settings.inc"
.include "src/customdata/customdata.inc"
.include "src/include/panel_memory.inc"
.include "src/include/voice_record.inc"

	.space	0x4000, 0xff	# erased

.org 0x4000
.include "src/ic21own/midi.inc"
	.space	0x155c, 0xff	# erased, to 0x6000

# ---- the flash test's pattern: 64 chunks of 0x80 bytes, as func_4849FCF2 programs them
.org 0x6000
FlashTest:
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
	FLASH_TEST_CHUNK
FlashTest_End:
	.space	0x8000, 0xff	# erased, to 0x10000

.org 0x10000
.include "src/ic21own/favorites.inc"
	.space	0xe68, 0xff	# erased, to 0x11000

.org 0x11000
.include "src/ic21own/homepage.inc"
	.space	0xabbe, 0xff	# erased, to 0x20000

.include "src/ic21own/custom.s"
