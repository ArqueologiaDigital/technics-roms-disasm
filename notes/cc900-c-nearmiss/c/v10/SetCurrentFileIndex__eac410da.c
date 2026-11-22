/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m268a.c (2026-11-22-9-p6-r76)
   sha256 eac410da4fc0a5bc0b884d949daa067bc6a3e1ee40d31cbdecaf8a09de453f1d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int ram_271ea;
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ValidateFileRangeType5(int);
extern void BuildPageRecords(void);
int SetCurrentFileIndex(int i)
{
	int r;
	int b;

	r = ValidateFileRangeType5(i);
	if (r == -1)
		return ram_271ea;
	if (r == 1) {
		b = (unsigned int)i / 60 * 60;
		ram_271ee = b;
		b += 59;
		FILE_LIST_LAST = b < ram_271ec ? b : ram_271ec;
		BuildPageRecords();
	}
	ram_271ea = i;
	return i;
}
