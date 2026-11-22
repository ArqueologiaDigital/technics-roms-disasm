/* lane_p6 helper M, round 28r1, form a: module 268 (demo/file_demo_proc.s), family of 2 x 76 B:
   SetCurrentFileIndex / FileIO_SelectFileByIndex.  One-spot retry of helper K's p6_K_27r1m268b (run r74,
   O3Xr equal to +67: the ROM copies the index into HL and stores HL, V4.23 stored IZ and then copied it).
   K's form b with the tail written `ram_271ea = i; return i;`.
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
	ram_271ea = i;
	return i;
}

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
	ram_271ea = i;
	return i;
}
