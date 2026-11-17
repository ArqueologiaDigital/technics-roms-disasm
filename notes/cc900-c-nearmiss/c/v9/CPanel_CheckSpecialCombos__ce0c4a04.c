/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/cpanel_routines_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 ce0c4a04c231acc401afc02ef9fcb558e79e5d17cfa237e77a66b0460b153110 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8e5e;
extern unsigned char __near ram_8e4b;
extern unsigned char __near ram_8e60;
extern unsigned char __near ram_8e50;
int CPanel_CheckSpecialCombos(void)
{
	int r;

	if (ram_8e5e == 108) r = 3;
	else if (ram_8e4b == 112) r = 2;
	else if (ram_8e60 == 56) r = 1;
	else if (ram_8e50 == 15) r = 4;
	else r = 0;
	return r;
}
