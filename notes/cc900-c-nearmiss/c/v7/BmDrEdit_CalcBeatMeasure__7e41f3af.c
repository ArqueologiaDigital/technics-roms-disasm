/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines_m232.c (2026-11-16-91-p6-r17)
   sha256 7e41f3af07b903b1bc5ee2d6beb4f7ab703228faff49fea5c27440cb032706ff (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_25d8;
extern unsigned char __near ram_2784;
extern unsigned char __near ram_27a4[];
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2782;
extern void BmDrEdit_CalcSongPosition(void);
extern void BmDrEdit_CalcSongPosition(void);
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
