/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m277a.c (2026-11-21-2-p6-r58)
   sha256 8810abc824f03cb9d70b6af1b16ba8c3c6ff9140c0e77de4821407326a2bac9a (tar-sha256); compiled at -Xr */
int PanelTlv_Rule_SetBits(unsigned char *rec, unsigned char *r)
{
  rec[r[1]] |= r[2];
  return 3;
}
