/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BuildPageRecords BuildSecondPageRecords FileIO_ScanDirEntries FileIO_ValidateModeAndRange ValidateFileRange ValidateFileRangeAlt ValidateFileRangeType5 ValidateFileSelectionIndex */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272ca;
extern int BuildPageRecords(void);
extern void BuildPageRecordsAlt(void);
extern int FileIO_ScanDirEntries(void);
extern void FileIO_InitWallpaperNav(void);
extern int BuildSecondPageRecords(void);
extern void GetFileCountEncoded(void);
extern int ram_25ea8, ram_271ea, ram_272c8;
extern int ValidateFileRangeAlt(int i);
extern int FileIO_GetCurrentFileIndex_Alt(void);
extern int FileIO_ValidateModeAndRange(int i);
extern int FileIO_GetCurrentWallpaperIndex(void);
extern int ValidateFileSelectionIndex(int i);
extern int GetCurrentFileIndex(void);
extern int ValidateFileRangeType5(int i);
extern int GetCurrentFileIndexAlt(void);
extern int ValidateFileRange(int i);
extern int GetFirstPageBase(void);

void BuildPageRecordsAlt(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildPageRecords();
	last = 0;
	if (n > 0)
		last = n - 1;
	ram_271ec = last;
	if (FILE_LIST_LAST > last)
		FILE_LIST_LAST = last;
}

void FileIO_InitWallpaperNav(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 9;
	n = FileIO_ScanDirEntries();
	last = 0;
	if (n > 0)
		last = n - 1;
	ram_272ca = last;
	if (FILE_LIST_LAST > last)
		FILE_LIST_LAST = last;
}

void GetFileCountEncoded(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildSecondPageRecords();
	last = 0;
	if (n > 0)
		last = n - 1;
	ram_271ec = last;
	if (FILE_LIST_LAST > last)
		FILE_LIST_LAST = last;
}

int FileIO_GetCurrentFileIndex_Alt(void)
{
	if (ValidateFileRangeAlt(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}

int FileIO_GetCurrentWallpaperIndex(void)
{
	if (FileIO_ValidateModeAndRange(ram_272c8) != 0)
		return -104;
	return ram_272c8;
}

int GetCurrentFileIndex(void)
{
	if (ValidateFileSelectionIndex(ram_25ea8) != 0)
		return -104;
	return ram_25ea8;
}

int GetCurrentFileIndexAlt(void)
{
	if (ValidateFileRangeType5(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}

int GetFirstPageBase(void)
{
	if (ValidateFileRange(ram_271ea) != 0)
		return -104;
	return ram_271ea;
}
