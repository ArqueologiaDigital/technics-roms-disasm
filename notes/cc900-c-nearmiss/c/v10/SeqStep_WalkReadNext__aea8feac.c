/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/seq_step_routines_m236.c (2026-11-16-68-p6-r12)
   sha256 aea8feac7119f4af4b5ff169aa1a5552ef2bfa643ec0896adcb74e772169e7bc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned int __near SQSTEP_SCAN_OFFSET;
extern unsigned int __near SQSTEP_SCAN_BLOCK;
int SeqStep_WalkReadNext(void)
{
	unsigned int o, b;

	o = SQSTEP_SCAN_OFFSET;
	if (o == 5) {
		b = PartCtrl_ReadWord_Off1(SQSTEP_SCAN_BLOCK);
		if (b == 0) return -1;
		SQSTEP_SCAN_BLOCK = b;
		SQSTEP_SCAN_OFFSET = 255;
	} else {
		SQSTEP_SCAN_OFFSET = o + 1;
	}
	return 0;
}
