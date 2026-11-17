/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/cpanel_routines_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 47e4178f1e100ed3af975785be0b41619f8b925b125df02b0913758740d6d349 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8dc2;
extern unsigned char __near ram_8daf;
extern unsigned char __near ram_8dc4;
extern unsigned char __near ram_8db4;
int CPanel_CheckSpecialCombos(void)
{
	int r;

	if (ram_8dc2 == 108) r = 3;
	else if (ram_8daf == 112) r = 2;
	else if (ram_8dc4 == 56) r = 1;
	else if (ram_8db4 == 15) r = 4;
	else r = 0;
	return r;
}
