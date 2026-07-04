# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# KN7000 "Program" flash image (kn7000_program.rom) - byte-exact skeleton.
#
# Panasonic MN10300 code, mapped at CPU address 0x48400000 (file offset + base).
# The boot header below is hand-disassembled; everything from 0x80 onwards is
# still pulled in verbatim as raw .incbin_range and awaits real disassembly.
# Disassemble with:  make disasm   (writes disasm/program.asm via MAME unidasm)

# 444 function names + the verified memory map, recovered from the firmware's
# own MILK-toolkit reflection tables (tools/gen_symbols.py). These names are
# shared with the KN5000 (same UI toolkit) -- see the kn5000-docs Shared
# Codebase Map. As raw .incbin regions below are converted into real
# disassembled code, calls/jumps can reference these symbols by name.
.include "src/symbols.inc"

# ============================================================================
# Boot header (0x000000 .. 0x000080)
#
# Two absolute jumps and a ROM-present marker byte, then 0xFF fill up to the
# start of code. mn10300 `jmp` = 0xDC + 32-bit little-endian target; the target
# equals PROGRAM_ROM_BASE + the stored value. There is no reset-vector table and
# no version byte anywhere in the shipped image (see NOTES in kn7000_extraction).
# ============================================================================
_reset:
    .byte 0xDC, 0x7E, 0xFF, 0x00, 0x00      # jmp  0x4840FF7E   (reset entry)
    .byte 0xCB                              # nop
    .byte 0xCB                              # nop
    .byte 0xCB                              # nop
    .byte 0xCB                              # nop
    .byte 0xCB                              # nop
_vector_0a:
    .byte 0xDC, 0xC5, 0x77, 0x0D, 0x00      # jmp  0x484D77CF
_rom_marker:
    .byte 0x16                              # ROM-present marker (firmware only
                                            #   ever compares this against 0xFF)
    .space 0x80 - 0x10, 0xFF                # 0xFF fill to 0x000080
    .org 0x000080

# ============================================================================
# Provisional section boundaries below. Everything is still a raw .incbin_range
# (nothing here is "understood" yet); the boundaries are the approximate region
# transitions found during analysis and exist only to guide the disassembly
# effort. Reconstruction is byte-exact regardless of where these splits fall.
# ============================================================================

# ---- code region 1 (main firmware) ----
.incbin_range "baserom/kn7000_program.rom", 0x000080, 0x186000

# ---- data / resources region ----
#   float64 dB-ratio table ~0x185DC0, multi-language UI text, FAT boot template,
#   flash-chip ID strings, RGB palettes, fonts, GUI resource tables, 9 JPEGs,
#   two Windows BMPs (clef @0x19E704, photo @0x345718).
.incbin_range "baserom/kn7000_program.rom", 0x186000, 0x3B8000

# ---- code region 2 (MILK MN10300 kernel + zlib 1.0.4) ----
#   kernel banner "MILK MN10300 Ver1.0R1" @0x3B8AAC,
#   zlib deflate/inflate banners @0x3B8604 / 0x3B863C.
.incbin_range "baserom/kn7000_program.rom", 0x3B8000, 0x3F6F01

.org 0x3F6F01   # end of image
