/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BuildPageRecords FileIO_InitDirScan ValidateFileRangeAlt ValidateFileRangeType5 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_271ea;
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ValidateFileRangeAlt(int);
extern void FileIO_InitDirScan(void);
extern int FileIO_SelectFileByIndex(int i);
extern int ValidateFileRangeType5(int);
extern void BuildPageRecords(void);
extern int SetCurrentFileIndex(int i);

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
	r = i;
	ram_271ea = r;
	return r;
}
