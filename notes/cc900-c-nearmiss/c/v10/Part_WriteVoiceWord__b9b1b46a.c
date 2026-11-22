/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m234a.c (2026-11-21-7-p6-r62)
   sha256 b9b1b46a2432dba0dd91c13e2770232bc1d05e2ed10a47087165b551167b55c7 (tar-sha256); compiled at -O3 -Xr */
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  c = c * 3 - 3;
  Part_WriteWord(a, (unsigned char)(c + 0xd1), v);
}
