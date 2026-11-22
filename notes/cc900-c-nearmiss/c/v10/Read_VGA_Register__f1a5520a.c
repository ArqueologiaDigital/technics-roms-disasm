/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_W_21r2m274a.c (2026-11-21-9-p6-r64)
   sha256 f1a5520ae938a11f81c82070eb6ed538426e7f8f2aa022bb83d68bb4920bdd9f (tar-sha256); compiled at -O3 -Xr */
/* helper W, round 21r2, module 274 (display/graphics_text_vga.s), form a: _Read_VGA_Register.  Run r62's best
   (p6_U_21r1m270a@O3Xr, `p = (unsigned char *)0x170000L; return p[r];`) folded the base into
   `add xwa, imm`; the ROM loads the base into XBC and adds the widened offset to it (`ld xbc, imm; add xbc, xwa`).
   Form a: the offset added to the pointer local in a statement of its own, then dereferenced.  Form b: the long
   offset added to the base held in a long local. */

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned char *p;
  p = (unsigned char *)0x170000L;
  p += r;
  return *p;
}
