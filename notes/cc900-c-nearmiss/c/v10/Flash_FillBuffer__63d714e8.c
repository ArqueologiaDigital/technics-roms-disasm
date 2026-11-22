/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m2b.c (2026-11-21-3-p6-r59)
   sha256 63d714e8ef38d65d8bacf883c9620ac5e73e17421923a9f2543dd722088144df (tar-sha256); compiled at -Xr */
void Flash_FillBuffer(unsigned int *p, unsigned int n)
{
  unsigned int i = 0;
  while (i < n) {
    *p++ = i;
    i++;
  }
}
