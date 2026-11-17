/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-17-1-p6-r28-staged)
   sha256 0b93ede3495b41ccdb73e984e0ba35d46ef5478b4898537d7cb80c4e3b6b8a41 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_2728;
extern unsigned char __near ram_27b2;
extern unsigned char __near NOTEEDIT_BASE_KEY;
void BmDrEdit_SetRowOffsetFromDelta(unsigned char a, unsigned char c)
{
	a -= c;
	if (ram_2728 & 1) {
		ram_27b2 = 11 - a;
		return;
	}
	c = a;
	ram_27b2 = a;
	if (NOTEEDIT_BASE_KEY != 0) return;
	c += 3;
	ram_27b2 = c;
}
