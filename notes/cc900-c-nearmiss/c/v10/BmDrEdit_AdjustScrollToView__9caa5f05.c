/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/bmdredit_routines_m232_xr.c (2026-11-16-125-p6-r26-staged)
   sha256 9caa5f053bb6276afc6a303e6119b2c4253cea93d507741d0b5c6835f3e6c417 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern void NoteEditSy_UpdateChordDisplay(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2962;
extern unsigned char __near ram_27ca;
extern unsigned char __near NOTEEDIT_BASE_KEY;
void BmDrEdit_AdjustScrollToView(void)
{
	unsigned char lo, hi;
	unsigned char c, k;

	if (ram_2742 & 1) return;
	ram_27ca = NOTEEDIT_BASE_KEY;
	for (;;) {
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		c = ram_2962;
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
	if (ram_27ca == NOTEEDIT_BASE_KEY) return;
	NoteEditSy_UpdateChordDisplay();
}
