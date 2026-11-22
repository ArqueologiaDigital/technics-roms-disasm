/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m129a.c (2026-11-21-2-p6-r58)
   sha256 3ee5c50f7b11a2ceddf5bd6235946a30ad037bed8f4fa93fc7aa7f592c9ef013 (tar-sha256); compiled at -O3 -XS -Xr */
unsigned char SeMenu_BitShiftMask(unsigned char m, unsigned char n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    m += m;
  return m;
}
