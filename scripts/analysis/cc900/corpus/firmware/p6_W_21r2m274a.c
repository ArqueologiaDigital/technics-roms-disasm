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
