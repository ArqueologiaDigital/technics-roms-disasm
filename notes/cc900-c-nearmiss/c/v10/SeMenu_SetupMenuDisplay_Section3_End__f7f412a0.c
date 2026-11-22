/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m129a.c (2026-11-21-3-p6-r59)
   sha256 f7f412a07b2a114b415c4c965d5f13e8d25e6b847a46e9b16fed5b93264c4542 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  ram_65c = a != 0;
}
