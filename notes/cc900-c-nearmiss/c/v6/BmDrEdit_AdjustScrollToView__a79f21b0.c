/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232_xr.c (2026-11-16-125-p6-r26-staged)
   sha256 a79f21b07f8644dc2b7a53c428bf3ed21142c7d1252e89a6afe58337ae385b4c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void NoteEditSy_UpdateChordDisplay(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern unsigned char __near ram_2728;
extern unsigned char __near ram_2946;
extern unsigned char __near ram_27b0;
extern unsigned char __near NOTEEDIT_BASE_KEY;
void BmDrEdit_AdjustScrollToView(void)
{
	unsigned char lo, hi;
	unsigned char c, k;

	if (ram_2728 & 1) return;
	ram_27b0 = NOTEEDIT_BASE_KEY;
	for (;;) {
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		c = ram_2946;
		k = NOTEEDIT_BASE_KEY;
		if (c < lo) {
			c = k;
			if (k == 0) return;
			c--;
			NOTEEDIT_BASE_KEY = c;
		} else if (c > hi) {
			c = k;
			if (k >= 9) return;
			c++;
			NOTEEDIT_BASE_KEY = c;
		} else
			break;
	}
	if (ram_27b0 == NOTEEDIT_BASE_KEY) return;
	NoteEditSy_UpdateChordDisplay();
}
