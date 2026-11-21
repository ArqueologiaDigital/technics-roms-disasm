/* helper W, round 21r2, module 274, form b: _Read_VGA_Register with the base in a long local, the widened offset
   added to it, and the sum used as the address. */

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned long b;
  b = 0x170000L;
  b += r;
  return *(unsigned char *)b;
}
