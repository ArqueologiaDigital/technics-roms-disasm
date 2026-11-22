/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m129a.c (2026-11-21-21-p6-r66)
   sha256 032346b3ca03bd3131f581224651d940360b1db40e77f05399b1b93bcf6be13b (tar-sha256); compiled at -Xr
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
