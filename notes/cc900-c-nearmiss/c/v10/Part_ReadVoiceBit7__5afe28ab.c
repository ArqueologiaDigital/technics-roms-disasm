/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m234b.c (2026-11-21-7-p6-r62)
   sha256 5afe28ab150c2a0066f966bbe7968e81fb1844ab29b8862275eec33b6fdf1cee (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  unsigned char o;
  o = c * 3 - 3;
  o += 0xd0;
  return Part_ReadByteDirect(a, o) & 0x80;
}
