/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m129b.c (2026-11-21-21-p6-r66)
   sha256 3ec87518826a85f641a840983abf6a6b09eb4292acd934125510dd2b4f2355da (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  if (a != 0)
    a = 1;
  else
    a = 0;
  ram_65c = a;
}
