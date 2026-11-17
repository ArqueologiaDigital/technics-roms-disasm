/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-16-91-p6-r17)
   sha256 7668811022092df20c6145217590dc7eda12887c2838b5f9b06c18b9faf2e457 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_25be;
extern unsigned char __near ram_276a;
extern unsigned char __near ram_278a[];
extern unsigned int __near ram_2780;
extern unsigned int __near ram_2758;
extern unsigned int __near ram_2768;
extern void BmDrEdit_CalcSongPosition(void);
extern void BmDrEdit_CalcSongPosition(void);
void BmDrEdit_CalcSongPosition(void);
void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int n, i;
	unsigned char *t;

	n = ram_2780 / 96;
	ram_25be = 0;
	ram_2758 = n;
	if (n != 0) {
		i = 1;
		ram_25be = 1;
		t = ram_278a;
		for (;;) {
			if (t[i] != 0) ram_25be = 0;
			i++;
			if ((ram_2758 = ram_2758 - 1) == 0) break;
			ram_25be++;
		}
	}
	ram_2768 = ram_25be;
	ram_276a = ram_2780 % 96;
	BmDrEdit_CalcSongPosition();
}
