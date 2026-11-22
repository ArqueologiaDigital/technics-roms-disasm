/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m129a.c (2026-11-21-9-p6-r64)
   sha256 1123df064e57010a88d4a683b148bce6df8e8e54ab3df758f6e0058575e032bd (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  a = a != 0;
  ram_65c = a;
}
