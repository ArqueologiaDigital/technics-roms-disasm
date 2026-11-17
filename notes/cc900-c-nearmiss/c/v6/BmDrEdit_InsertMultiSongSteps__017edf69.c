/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-16-125-p6-r26-staged)
   sha256 017edf69f2efe09b667a86707fe731921926ec2ef18bb1a035f47a78d8991cc4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern unsigned char BmDrEdit_ProcessVoiceSection(unsigned int, unsigned int *, unsigned int *);
extern void EditChannel_LoadVoiceParams(void);
extern void BmDrEdit_InsertStepEntry(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2744;
extern unsigned int __near ram_ce3;
extern unsigned int __near ram_2758;
extern unsigned int __near ram_272a;
void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2758;
	ram_2744 = ram_2758;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_272a == a) goto out;
		if (b != 0) r -= b;
		ram_2758 = r;
		do {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) goto out;
			ram_2744++;
		} while (--ram_2758 != 0);
		ram_ce3 = ram_2744;
	}
out:
	;
}
