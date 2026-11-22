/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m234b.c (2026-11-21-2-p6-r58)
   sha256 43ed1f03973386274f66479c5d07d8f5730dc3ff1863c974a77499b3e119848d (tar-sha256); compiled at -O3 -XS -Xr */
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned char o;
  o = c * 3;
  o -= 3;
  o += 0xd1;
  Part_WriteWord(a, o, v);
}
