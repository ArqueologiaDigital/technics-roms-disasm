/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: BuildSecondPageRecords FileIO_ScanDirEntries FileIO_ValidateModeAndRange ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern int FileIO_ValidateModeAndRange(int i);
extern void FileIO_ScanDirEntries(void);
extern int FileIO_SelectWallpaperByIndex(int i);
extern int ValidateFileRange(int i);
extern void BuildSecondPageRecords(void);
extern int NavigateToFileIndex(int i);

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
