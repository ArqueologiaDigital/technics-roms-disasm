/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m240b.c (2026-11-21-2-p6-r58)
   sha256 b912c633906d1f67b33b42a6423716c931e0a0d7043cf9fe7bfe66c49d127c89 (tar-sha256); compiled at -O3 -XS -Xr */
extern int FDC_Format2HD_Start(void);
extern int FDC_Format2DD_Start(void);
int format_FD(int t)
{
  unsigned int k;
  k = (unsigned char)t;
  if (k == 3) return FDC_Format2HD_Start();
  if (k == 2) return FDC_Format2DD_Start();
  return 0;
}
