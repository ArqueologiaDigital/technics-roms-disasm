/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m234a.c (2026-11-21-7-p6-r62)
   sha256 b9b1b46a2432dba0dd91c13e2770232bc1d05e2ed10a47087165b551167b55c7 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int Part_ReadWord(unsigned int, unsigned int);
unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  c = c * 3 - 3;
  return Part_ReadWord(a, (unsigned char)(c + 0xd1));
}
