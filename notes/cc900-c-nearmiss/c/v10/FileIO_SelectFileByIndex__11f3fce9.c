/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m268a.c (2026-11-22-7-p6-r74)
   sha256 11f3fce9fa116ccda185d6bd2081685a6a808eccecd0f041307709de9124c21e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int ram_271ea;
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ValidateFileRangeAlt(int);
extern void FileIO_InitDirScan(void);
int FileIO_SelectFileByIndex(int i)
{
	int r;
	int b;
	int n;

	r = ValidateFileRangeAlt(i);
	if (r == -1)
		return ram_271ea;
	if (r == 1) {
		b = (unsigned int)i / 60 * 60;
		ram_271ee = b;
		b += 59;
		n = ram_271ec;
		if (b < n)
			n = b;
		FILE_LIST_LAST = n;
		FileIO_InitDirScan();
	}
	ram_271ea = i;
	return i;
}
