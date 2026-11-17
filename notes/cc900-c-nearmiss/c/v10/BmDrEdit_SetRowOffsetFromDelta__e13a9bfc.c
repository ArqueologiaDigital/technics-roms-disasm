/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m232b.c (2026-11-16-128-p6-r27)
   sha256 e13a9bfc20e710c5df7360c10e306da34ce0c598c029e5e76b00a83eeb896b85 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2742;
extern unsigned char __near ram_27cc;
extern unsigned char __near NOTEEDIT_BASE_KEY;
void BmDrEdit_SetRowOffsetFromDelta(unsigned char a, unsigned char c)
{
	a -= c;
	if (ram_2742 & 1) {
		ram_27cc = 11 - a;
		return;
	}
	ram_27cc = c = a;
	if (NOTEEDIT_BASE_KEY != 0) return;
	c += 3;
	ram_27cc = c;
}
