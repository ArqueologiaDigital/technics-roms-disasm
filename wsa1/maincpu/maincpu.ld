/* maincpu.ld -- ONE link for CPU 1's program, which lives in two EPROMs
 *
 * IC13 (prom_b) holds 0xF00000-0xF7FFFF and IC12 (prom_a) 0xF80000-0xFFFFFF:
 * one contiguous 1 MiB window on CS2 (MSAR2 = 0xE0 / MAMR2 = 0x3F / B2CS =
 * 0x1B), one program.  The two images are still assembled as two objects
 * (rebuilt_ROMs/wsa1_prom_{b,a}.llvm.o, made rebuilt_ROMs/*.link.o by
 * prom_X/exports.syms), but they are linked
 * together here, so a label one image names in the other is resolved by
 * ld.lld instead of being copied in as an address.  Each image declares
 * `.global` the labels the other references (the EXPORTS block near the top of
 * prom_X/wsa1_prom_X.s); every other label stays local to its object, so the
 * routines the program carries twice (maincpu/shared/) still bind per image,
 * nearest copy, as the firmware does.
 *
 * The Makefile cuts the two EPROM images out of the one ELF with
 * `llvm-objcopy -O binary -j .prom_b` / `-j .prom_a`, and writes the per-image
 * ELF views wsa1_prom_{a,b}.llvm.elf (`-j` again) that the analysis tools read.
 *
 * The memory map, and the evidence for both bases, stays in prom_a/prom_a.ld
 * and prom_b/prom_b.ld, which are no longer link inputs.
 * scripts/tools/join_maincpu_link.py (phase B3, notes/PLAN-join-and-split.md
 * sec 10) did the rewrite and carries its proof.
 */

MEMORY {
  PROM_B (rx) : ORIGIN = 0xF00000, LENGTH = 512K
  PROM_A (rx) : ORIGIN = 0xF80000, LENGTH = 512K
}

SECTIONS {
  .prom_b 0xF00000 : { *wsa1_prom_b.link.o(.text*) } > PROM_B
  .prom_a 0xF80000 : { *wsa1_prom_a.link.o(.text*) } > PROM_A
  /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}

/* prom_b's last instruction, `jr z` at 0xF7FFFE, branches across the chip boundary.  The backend
 * has no 8-bit PC-relative relocation, so prom_b spells that one target as a local equate
 * (prom_b/modules/f7d000_f7ffff_panel_screen_methods.s); this checks the equate against the label. */
ASSERT(AdvanceDelay_SelectField1_Ret == 0xF80019,
       "prom_b's jr at 0xF7FFFE: AdvanceDelay_SelectField1_Ret moved; update its equate in prom_b")
