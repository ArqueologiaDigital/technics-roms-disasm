/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/semenu_routines_m129.c (2026-11-21-22-p6-r67)
   sha256 cf82d66965efb74bfb0d3ccda2f3a7701471eedd8d2359ae9ee700f594560131 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  unsigned char f;
  if (a)
    f = 1;
  else
    f = 0;
  ram_65c = f;
}
