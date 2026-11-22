/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m270a.c (2026-11-21-3-p6-r59)
   sha256 3ffccd424c5aea4fdabe171ccde8ab864d5b56bad79d5e2ab7240804b061b46e (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_8d4a;
unsigned char BitMapOut_GetRenderMode_CheckBit3(unsigned char a)
{
  unsigned char *p = &ram_8d4a;
  *p |= a;
  return *p;
}
