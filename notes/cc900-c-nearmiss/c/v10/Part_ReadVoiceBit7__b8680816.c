/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m234a.c (2026-11-21-3-p6-r59)
   sha256 b86808166a06d60625b10f675d0d7cd1a33d597b82e5099a43dcbbaebf33208e (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (unsigned char)((c - 1) * 3 + 0xd0)) & 0x80;
}
