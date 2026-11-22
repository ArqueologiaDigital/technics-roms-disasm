/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/semenu_routines_m129.c (2026-11-21-5-p6-r60)
   sha256 457594703b060a2e0a29348a2fdfd32d7be43e9823ecac4640c61050e001b9a4 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
unsigned char SeMenu_BitShiftMask(unsigned char m, unsigned char n)
{
  unsigned int i;
  for (i = 0; i < n; i++)
    m += m;
  return m;
}
