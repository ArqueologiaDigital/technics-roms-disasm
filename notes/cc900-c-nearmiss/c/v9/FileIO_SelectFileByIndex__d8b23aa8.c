/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/file_demo_proc_m268.c (2026-11-22-10-p6-r77)
   sha256 d8b23aa807ed6b0e2cb0e8222c79f6b308489c4ae8a85f9b41e28e09e8fc13e4 (tar-sha256); compiled at -Xr
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

	r = ValidateFileRangeAlt(i);
	if (r == -1)
		return ram_271ea;
	if (r == 1) {
		b = (unsigned int)i / 60 * 60;
		ram_271ee = b;
		b += 59;
		FILE_LIST_LAST = b < ram_271ec ? b : ram_271ec;
		FileIO_InitDirScan();
	}
	r = i;
	ram_271ea = r;
	return r;
}
