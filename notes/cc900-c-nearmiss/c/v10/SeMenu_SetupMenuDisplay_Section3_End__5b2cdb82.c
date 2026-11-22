/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m129a.c (2026-11-21-7-p6-r62)
   sha256 5b2cdb82784f9f48b4e861f3495d96211ed683f33481244c266e9727acc59248 (tar-sha256); compiled at -O3 -Xr
   cc900-name: SeMenu_SMD_Sec3End=SeMenu_SetupMenuDisplay_Section3_End */
extern unsigned char __near ram_65c;
void SeMenu_SMD_Sec3End(unsigned char a)
{
  a = a != 0;
  ram_65c = a;
}
