/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m232.c (2026-11-16-123-p6-r25)
   sha256 b6d8d7c2146514593eec82af6592d8630f8da28dc76c06cf50954ca1feca79eb (tar-sha256); compiled at -O3 -Xr */
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
