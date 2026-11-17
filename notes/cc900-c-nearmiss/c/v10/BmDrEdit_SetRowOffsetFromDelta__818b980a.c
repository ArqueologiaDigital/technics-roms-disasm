/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/bmdredit_routines_m232.c (2026-11-17-1-p6-r28-staged)
   sha256 818b980a230471890e9aaa1729c30aab030c80de5af46356e2a6937420b598bf (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
	c = a;
	ram_27cc = a;
	if (NOTEEDIT_BASE_KEY != 0) return;
	c += 3;
	ram_27cc = c;
}
