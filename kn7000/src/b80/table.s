# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# KN7000 "Table" flash image, build 80 - byte-exact.
#
# Build 80 is the table that pairs with program 893 (v1.3); the reference is the
# read of Felipe's own instrument (IC17/IC16, private romset, de-interleaved by
# tools/rom_from_eproms.py: `make baserom/kn7000_table_b80.rom`).
#
# It is SP7001 table 83's directory image (85-entry directory, segments 00..83,
# 0x3E0660 bytes) with ONE byte changed: the second digit of the build string in
# segment 07. Build 83 then appends its XAPR plug-in at 0x3E8000; build 80 has
# none, so the rest of the 4 MB is erased flash. Rather than copy table 83's
# source, this takes the bytes of build/kn7000_table_sp7001.rom, the image that
# src/sp7001/table.s assembles to and `make verify-sp7001` checks, so whatever
# typing that source gains, build 80 is checked against it too.
#
# `make verify-table80` assembles this and compares it with the reference.

.mnbase 0x48000000   # CPU address of output offset 0

.incbin_range "build/kn7000_table_sp7001.rom", 0x000000, 0x139EE8   # directory, seg00..seg06: as build 83

# seg07 (dir[7] = 0x139EE8), the table's 4-byte build marker
# (notes/sp7001-build-diff.md): "84\n" in build 84, "83\n" in build 83.
TableBuildString:
    .ascii  "80\n"
    .byte   0

.incbin_range "build/kn7000_table_sp7001.rom", 0x139EEC, 0x3E0660   # seg08..seg83: as build 83

# Build 83's XAPR plug-in starts at 0x3E8000; build 80's flash is erased from
# the end of the directory image to the end of the chip.
    .space  0x400000 - 0x3E0660, 0xFF
    .org    0x400000
