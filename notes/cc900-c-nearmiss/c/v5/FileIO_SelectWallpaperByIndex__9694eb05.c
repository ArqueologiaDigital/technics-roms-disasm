/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268_xr.c (2026-11-19-43-p6-r48)
   sha256 9694eb0596771c5a82b75ac44053648163926bc9df3f010a761d55305f4e38a9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern int ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern int FileIO_ValidateModeAndRange(int i);
extern void FileIO_ScanDirEntries(void);
int FileIO_SelectWallpaperByIndex(int i)
{
	int r;
	int t;
	int last;

	r = FileIO_ValidateModeAndRange(i);
	if (r == -1)
		return ram_272c8;
	if (r == 1) {
		t = (unsigned int)i / 10 * 10;
		ram_271ee = t;
		t += 9;
		last = ram_272ca;
		if (t < last)
			last = t;
		FILE_LIST_LAST = last;
		FileIO_ScanDirEntries();
	}
	return ram_272c8 = i;
}
