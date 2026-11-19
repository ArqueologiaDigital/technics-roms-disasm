/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_5m268b.c (2026-11-19-37-p6-r47)
   sha256 4f7960e8362009faeef643021f24f92e139a633a06bdb331c2eba397d8b09907 (tar-sha256); compiled at -O3 -Xr */
extern int ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern int ValidateFileRange(int i);
extern void BuildSecondPageRecords(void);
int NavigateToFileIndex(int i)
{
	int r;
	int t;
	int last;

	r = ValidateFileRange(i);
	if (r == -1)
		return ram_271ea;
	if (r == 1) {
		t = (unsigned int)i / 60 * 60;
		ram_271ee = t;
		t += 59;
		last = ram_271ec;
		if (t < last)
			last = t;
		FILE_LIST_LAST = last;
		BuildSecondPageRecords();
	}
	return ram_271ea = i;
}
