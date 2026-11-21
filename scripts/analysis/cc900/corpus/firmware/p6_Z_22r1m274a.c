/* helper Z, round 22r1, module 274 (display/graphics_text_vga.s), form a: _Read_VGA_Register.  Run r64's best
   (p6_W_21r2m274b@Xr) differed at +0: the ROM widens the offset first (`extz xwa`) and only then loads the base
   into XBC (`ld xbc, 0x170000; add xbc, xwa`).  Here the widening is a statement of its own into a long local,
   before the base pointer local is set; then the pointer is indexed with the long.  Form b: the long added to the
   pointer local, then dereferenced. */

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned long o;
  unsigned char *p;
  o = r;
  p = (unsigned char *)0x170000L;
  return p[o];
}
