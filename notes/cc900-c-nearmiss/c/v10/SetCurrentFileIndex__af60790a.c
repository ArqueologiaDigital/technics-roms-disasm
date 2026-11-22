/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m268b.c (2026-11-22-7-p6-r74)
   sha256 af60790aa9cc540f6f6ab8e6a849d4f4bfcfdb939bf5e4e2ae92866b58b41fde (tar-sha256); compiled at -O3 -Xr
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
	return ram_271ea = i;
}
