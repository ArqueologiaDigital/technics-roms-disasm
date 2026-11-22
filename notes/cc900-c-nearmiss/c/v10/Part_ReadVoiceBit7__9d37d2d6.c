/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m234b.c (2026-11-21-9-p6-r64)
   sha256 9d37d2d6c2508a1c6f696b26c3e933ea2a8e7f164e6d47903a2afbd50afe2274 (tar-sha256); compiled at -Xr */
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  unsigned int s;
  s = a;
  c *= 3;
  c -= 3;
  c += 0xd0;
  return Part_ReadByteDirect(s, c) & 0x80;
}
