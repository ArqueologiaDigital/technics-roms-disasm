/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m243b.c (2026-11-21-3-p6-r59)
   sha256 1b58ed586df881f127e47e27111620ba9508500d581cb85f8ae8cfd27407ac80 (tar-sha256); compiled at -Xr */
void SoundMem_ClearRegion(void)
{
  unsigned char *p;
  for (p = (unsigned char *)0xffc00L; p < (unsigned char *)0x100000L; p++)
    *p = 0;
}
