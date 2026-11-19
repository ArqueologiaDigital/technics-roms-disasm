/* Phase 6, lane_p6 helper L, round 5, form b: module 268, the NavigateToFileIndex / FileIO_SelectWallpaperByIndex
   twins with the clamp as the ROM's register does it: last = count; if (t < count) last = t. */
/* cc900-module: BuildSecondPageRecords FileIO_ScanDirEntries FileIO_ValidateModeAndRange ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern int ValidateFileRange(int i);
extern void BuildSecondPageRecords(void);
extern int FileIO_ValidateModeAndRange(int i);
extern void FileIO_ScanDirEntries(void);
extern int NavigateToFileIndex(int i);
extern int FileIO_SelectWallpaperByIndex(int i);

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
