/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m268c.c (2026-11-22-9-p6-r76)
   sha256 fa57e39eaa3272982d5272154659d5f6d0fa726ec081d5d9bbff3693cfc86376 (tar-sha256); compiled at -Xr
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
	ram_271ea = r = i;
	return r;
}
