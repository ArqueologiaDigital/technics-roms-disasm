# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# KN7000 SP7001 "Program" flash image (build 942) - byte-exact.
# Panasonic MN10300, mapped at CPU 0x48400000.
#
# SP7001 (program build 942) is a near-total rebuild of build 941 (this repo's
# default target): ~83% of the 4 MiB differs and it is NOT a clean relocation
# (see notes/sp7001-build-diff.md), so it carries its own image rather than a
# patch over program.s. This file starts as a byte-exact passthrough; the
# SP7001-unique functions (floppy->SD song-conversion + the activation gate)
# are converted to annotated MN10300 as the focused RE progresses, reusing the
# 941 symbol names for everything shared. `make verify-sp7001` guarantees
# byte-identity throughout.

.equ PROGRAM_ROM_BASE, 0x48400000
.mnbase 0x48400000   # CPU address of output offset 0 (for PC-relative ops)

.incbin_range "baserom/kn7000_program_sp7001.rom", 0x000000, 0x400000
.org 0x400000
