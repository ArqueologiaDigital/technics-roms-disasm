/* Phase 6, lane_p6 helper D, round 9, module 232 (v10 sequencer/bmdredit_routines.s), form a: BmDrEdit_CalcBeatMeasure,
   which ends in a jump to BmDrEdit_CalcSongPosition (the next routine), and that routine.  The remainder is read
   from the high word of the 32-bit quotient (QWA), which the checker can now translate. */
/* cc900-module: BmDrEdit_CalcSongPosition */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_25d8;
extern unsigned char __near ram_2784;
extern unsigned char __near ram_27a4[];
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2782;
extern unsigned int __near ram_27b2;
extern unsigned int __near ram_2744;

void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int n, i;
	unsigned char *t;

	n = ram_279a / 96;
	ram_25d8 = 0;
	ram_2772 = n;
	if (n != 0) {
		i = 1;
		ram_25d8 = 1;
		t = ram_27a4;
		for (;;) {
			if (t[i] != 0) ram_25d8 = 0;
			i++;
			if ((ram_2772 = ram_2772 - 1) == 0) break;
			ram_25d8++;
		}
	}
	ram_2782 = ram_25d8;
	ram_2784 = ram_279a % 96;
	BmDrEdit_CalcSongPosition();
}

void BmDrEdit_CalcSongPosition(void)
{
	unsigned int i, n;
	unsigned char *t;
	unsigned int p;

	n = ram_279a / 96;
	ram_25d8 = 0;
	ram_2772 = n;
	if (n != 0) {
		i = 1;
		ram_25d8 = 0;
		t = ram_27a4;
		do {
			if (t[i] != 0) ram_25d8++;
			i++;
		} while ((ram_2772 = ram_2772 - 1) != 0);
	}
	p = ram_27b2;
	ram_2744 = p + ram_25d8;
}
