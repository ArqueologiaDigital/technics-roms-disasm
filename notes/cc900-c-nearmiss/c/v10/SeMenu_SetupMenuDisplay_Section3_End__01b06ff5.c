/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m129b.c (2026-11-21-3-p6-r59)
   sha256 01b06ff5627c47a3959f89ac4b2d97c6c03bc8a62dad6e5f8d0d145fae79e2fa (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  unsigned char f = a != 0;
  ram_65c = f;
}
