/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m234b.c (2026-11-21-3-p6-r59)
   sha256 bafb1ec50e4615f1aca50e01fb26d5f26fea7966125f481d24e4a421768ec32c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (unsigned char)(c * 3 - 3 + 0xd0)) & 0x80;
}
