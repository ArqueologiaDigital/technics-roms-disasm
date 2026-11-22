/* lane_p6 helper J, round 27r1, form e: module 268 (demo/file_demo_proc.s), the family FileIO_InitWallpaperNav /
   BuildPageRecordsAlt / GetFileCountEncoded (families27_J, 3 x 45 B): first index 0x271ee = 0, last index
   FILE_LIST_LAST = 9 / 59, build the page (FileIO_ScanDirEntries / BuildPageRecords / BuildSecondPageRecords, HL =
   the entry count), store count - 1 (0 when none) in 0x272ca / 0x271ec and lower FILE_LIST_LAST to it (`ret le`).
   (Forms a-c of this round's m268 hold the SINGLE LOAD name readers; this file only the page-count family.)
   Form e: `last = n > 0 ? n - 1 : 0;` and `if (last < FILE_LIST_LAST)` (form d: if statement, cell on the left).
   cc900-options: -O3 -Xr
*/
/* cc900-module: BuildPageRecords BuildSecondPageRecords FileIO_ScanDirEntries */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272ca;
extern int FileIO_ScanDirEntries(void);
extern int BuildPageRecords(void);
extern int BuildSecondPageRecords(void);

void FileIO_InitWallpaperNav(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 9;
	n = FileIO_ScanDirEntries();
	last = n > 0 ? n - 1 : 0;
	ram_272ca = last;
	if (last < FILE_LIST_LAST)
		FILE_LIST_LAST = last;
}

void BuildPageRecordsAlt(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildPageRecords();
	last = n > 0 ? n - 1 : 0;
	ram_271ec = last;
	if (last < FILE_LIST_LAST)
		FILE_LIST_LAST = last;
}

void GetFileCountEncoded(void)
{
	int n;
	int last;

	ram_271ee = 0;
	FILE_LIST_LAST = 59;
	n = BuildSecondPageRecords();
	last = n > 0 ? n - 1 : 0;
	ram_271ec = last;
	if (last < FILE_LIST_LAST)
		FILE_LIST_LAST = last;
}
