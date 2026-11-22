/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_W_21r2m274b.c (2026-11-21-9-p6-r64)
   sha256 c6a6bc05b8b5bd57d3601faee6870ca233e1816052f522b3b81366511217298f (tar-sha256); compiled at -O3 -Xr */
/* helper W, round 21r2, module 274, form b: _Read_VGA_Register with the base in a long local, the widened offset
   added to it, and the sum used as the address. */

unsigned char _Read_VGA_Register(unsigned int r)
{
  unsigned long b;
  b = 0x170000L;
  b += r;
  return *(unsigned char *)b;
}
