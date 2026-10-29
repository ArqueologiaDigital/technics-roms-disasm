/* waveform.ld - Linker script for the KN5000 waveform ROM IC307 (LLVM build)
 *
 * No CPU addresses this ROM: the tone generator IC303 reads it on its own bus,
 * at an address we do not know.  The image is linked at 0, so a label's value is
 * its file offset (page p starts at p * 0x100000).
 */

MEMORY {
  ROM (r) : ORIGIN = 0, LENGTH = 4M
}

SECTIONS {
  .text 0 : { *(.text*) } > ROM
  /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
