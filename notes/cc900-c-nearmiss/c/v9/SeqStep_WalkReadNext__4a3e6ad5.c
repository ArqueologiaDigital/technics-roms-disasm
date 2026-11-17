/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/seq_step_routines.c (2026-11-16-55-p6-r10)
   sha256 4a3e6ad55338a99412a696e17fe9531f54b9f068257d023aa5e7fd7106c993a3 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
