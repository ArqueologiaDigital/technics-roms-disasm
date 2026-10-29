/* rhythm_data.ld - Linker script for the KN5000 rhythm data ROM IC14 (LLVM build)
 *
 * Memory map:
 *   The main CPU maps IC14 at 0x400000-0x7FFFFF (4 MB); AccVoice_OffsetTable lists its
 *   64 banks of 64 KB from 0x400000.
 */

MEMORY {
  ROM (r) : ORIGIN = 0x400000, LENGTH = 4M
}

SECTIONS {
  .text 0x400000 : { *(.text*) } > ROM
  /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
