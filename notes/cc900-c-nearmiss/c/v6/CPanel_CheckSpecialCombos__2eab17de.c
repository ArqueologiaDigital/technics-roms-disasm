/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/cpanel_routines_xr.c (2026-11-16-36-p6-staged-r4)
   sha256 2eab17de48a17d82d3c1a5bcc0b168d40f5fa57fee84cbd2063f3727bebf6287 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern unsigned char __near ram_8d9e;
extern unsigned char __near ram_8d8b;
extern unsigned char __near ram_8da0;
extern unsigned char __near ram_8d90;
int CPanel_CheckSpecialCombos(void)
{
	int r;

	if (ram_8d9e == 108) r = 3;
	else if (ram_8d8b == 112) r = 2;
	else if (ram_8da0 == 56) r = 1;
	else if (ram_8d90 == 15) r = 4;
	else r = 0;
	return r;
}
