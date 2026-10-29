# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# All of IC18 (C3CBND000046, 4 MB), the KN7000's rhythm ROM, byte-exact:
#   0x000000-0x00FFFF  the boot ROM (boot.s; notes/ic18-boot-rom.md)
#   0x010000-0x3FFFFF  the "Technics Rhythms" style resource (rhythm.s;
#                      notes/ic18-rhythm-rom.md)
# `make verify-ic18-full` assembles it and compares it with the chip.
.include "src/ic18/boot.s"
.include "src/ic18/rhythm.s"
