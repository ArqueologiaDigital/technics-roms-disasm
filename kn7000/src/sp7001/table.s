# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# KN7000 SP7001 "Table" flash image (build 83) - byte-exact.
# Mapped at CPU 0x48000000.
#
# Table build 83 (paired with the SP7001 program) differs from build 84 in one
# dominant ~1.78 MiB block (0x48244F7A..0x483F8868) plus small tails; that block
# contains the SP7001 activation/conversion CODE at ~0x483E0000..0x483FBFFF
# (the gate reverse-engineered in research-scratch/kn7000-sp7001-activation/:
# OK-handler 0x483E9E1C, comparator 0x483EF0AF, keystream 0x483F8B74). This file
# starts as a byte-exact passthrough; the SP7001 code slice is converted to
# annotated MN10300 as the focused RE progresses. See notes/sp7001-build-diff.md.

.equ TABLE_ROM_BASE, 0x48000000
.mnbase 0x48000000

.incbin_range "baserom/kn7000_table_sp7001.rom", 0x000000, 0x400000
.org 0x400000
