/* lane_p6 helper K, round 27r1, form a: module 268 (demo/file_demo_proc.s), family of 2 x 76 B:
   SetCurrentFileIndex / FileIO_SelectFileByIndex.  Validate the index (ValidateFileRangeType5 /
   ValidateFileRangeAlt): -1 keeps and returns the current index; 1 (off the page) moves the page to the index's
   60-entry page, ends it at the smaller of page + 59 and the list's last index, and rebuilds the page
   (BuildPageRecords / FileIO_InitDirScan); then the index is stored and returned.  Cells as in the built
   file_demo_proc_b.c (plain 24-bit ints).  Form a: the page end by a min through a local.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BuildPageRecords FileIO_InitDirScan ValidateFileRangeAlt ValidateFileRangeType5 */

extern int ram_271ea;
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ValidateFileRangeType5(int);
extern int ValidateFileRangeAlt(int);
extern void BuildPageRecords(void);
extern void FileIO_InitDirScan(void);

int SetCurrentFileIndex(int i)
{
	int r;
	int b;
	int n;

	r = ValidateFileRangeType5(i);
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
		BuildPageRecords();
	}
	ram_271ea = i;
	return i;
}

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
