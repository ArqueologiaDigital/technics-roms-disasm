/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_16m232b.c (2026-11-16-118-p6-r23)
   sha256 17133d587e147c5c85f2ee9c7938b59449a0c595a64f0306a4af8a37a7dd1332 (tar-sha256); compiled at -O3 -Xr */
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
	unsigned int ch;
	unsigned char r;

	ram_ce3 = ram_2772;
	ram_275e = ram_2772;
	for (;;) {
		ch = BmDrEdit_CheckAndSelectChannel();
		r = BmDrEdit_ProcessVoiceSection(ch, &a, &b);
		if (ram_2744 == a) return;
		if (b != 0) r -= (unsigned char)b;
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
