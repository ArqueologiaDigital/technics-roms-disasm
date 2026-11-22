/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/tonegen_fileio_handlers_m277.c (2026-11-21-5-p6-r60)
   sha256 7cb499078d089757f9de57f7fda583e475827a3c32fdc4d8dd8126897c30dd7f (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
int PanelTlv_Rule_StoreByte(unsigned char *base, unsigned char *rule)
{
  base[rule[1]] = rule[2];
  return 3;
}
