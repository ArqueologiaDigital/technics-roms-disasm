/* helper Z, round 22r1, module 274 (display/graphics_text_vga.s), form b: _Read_VGA_Register, as form a but the
   widened offset added to the pointer local in a statement of its own, then dereferenced. */

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned long o;
  unsigned char *p;
  o = r;
  p = (unsigned char *)0x170000L;
  p += o;
  return *p;
}
