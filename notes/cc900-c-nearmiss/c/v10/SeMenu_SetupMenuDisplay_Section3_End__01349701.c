/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m129b.c (2026-11-21-7-p6-r62)
   sha256 013497011cbe31f17f545c1173838b710303137174c4f3fb9fefd959eaa14345 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  ram_65c = (unsigned char)(a != 0);
}
