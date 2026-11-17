/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m232.c (2026-11-16-118-p6-r23)
   sha256 a1f2035416f0f07618277d0127c7c6434bb33ff1c25975f9e621002b9c0b8651 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern unsigned char BmDrEdit_ProcessVoiceSection(unsigned int, unsigned int *, unsigned int *);
extern void EditChannel_LoadVoiceParams(void);
extern void BmDrEdit_InsertStepEntry(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_275e;
extern unsigned int __near ram_ce3;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2744;
void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2772;
	ram_275e = ram_2772;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_2744 == a) return;
		if (b != 0) r -= b;
		ram_2772 = r;
		do {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) return;
			ram_275e++;
		} while (--ram_2772 != 0);
		ram_ce3 = ram_275e;
	}
}
