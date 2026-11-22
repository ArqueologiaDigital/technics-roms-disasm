/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/semenu_routines_m129.c (2026-11-21-5-p6-r60)
   sha256 1833218c1e9611869d7c0d13851464ef01155a5ac41c1c017d9b5c4a01d77503 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
unsigned char SeMenu_BitShiftMask(unsigned char m, unsigned char n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    m += m;
  return m;
}
