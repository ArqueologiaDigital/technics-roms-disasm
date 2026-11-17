/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m232b.c (2026-11-16-123-p6-r25)
   sha256 f52683040d90b74fc5729101b4cac0db35bfe0b2e33c398603c91569097b5428 (tar-sha256); compiled at -Xr */
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
		if (ram_2744 == a) break;
		if (b != 0) r -= b;
		ram_2772 = r;
		for (;;) {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) goto out;
			ram_275e++;
			if (--ram_2772 == 0) break;
		}
		ram_ce3 = ram_275e;
	}
out:
	;
}
