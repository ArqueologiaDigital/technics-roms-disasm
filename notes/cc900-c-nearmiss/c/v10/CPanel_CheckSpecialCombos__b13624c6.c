/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
extern unsigned char __near ram_8e5e;
extern unsigned char __near ram_8e4b;
extern unsigned char __near ram_8e60;
extern unsigned char __near ram_8e50;
int CPanel_CheckSpecialCombos(void)
{
	if (ram_8e5e == 108) return 3;
	if (ram_8e4b == 112) return 2;
	if (ram_8e60 == 56) return 1;
	if (ram_8e50 == 15) return 4;
	return 0;
}
