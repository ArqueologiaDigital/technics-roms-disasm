/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m234b.c (2026-11-21-7-p6-r62)
   sha256 5afe28ab150c2a0066f966bbe7968e81fb1844ab29b8862275eec33b6fdf1cee (tar-sha256); compiled at -O3 -Xr */
extern unsigned int Part_ReadWord(unsigned int, unsigned int);
unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  unsigned char o;
  o = c * 3 - 3;
  o += 0xd1;
  return Part_ReadWord(a, o);
}
