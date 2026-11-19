/* Phase 6, lane_p6 helper L, round 5, form a: module 268 (demo/file_demo_proc.s), new.  Cells as the matched
   cc900/file_demo_proc_b.c declares them (its ValidateFileRange is this file's callee).
   - NavigateToFileIndex / FileIO_SelectWallpaperByIndex: a twin pair.  -1 from the range check returns the current
     index; 1 (outside the page) sets the page start (unsigned i / 60 * 60, resp. / 10 * 10), the last row
     (start + 59, resp. + 9, clamped to the count) and rebuilds the page; then stores and returns the new index.
     Form a clamps with a conditional expression.
   - FileIO_SearchAndLoadFile: the volume path at 0x25d74, from the volume label when that is found, else the
     default "____" name (a short C name: its label is longer than 31 characters). */
/* cc900-module: BuildSecondPageRecords FileIO_CopyString FileIO_ScanDirEntries FileIO_SearchFile FileIO_ValidateModeAndRange ValidateFileRange */   /* scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: SearchLoadDefStr=SearchLoad_DefaultVolume_Str_Under_Under_Under_Under */
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

	r = ValidateFileRange(i);
	if (r == -1)
		return ram_271ea;
	if (r == 1) {
		t = (unsigned int)i / 60 * 60;
		ram_271ee = t;
		t += 59;
		FILE_LIST_LAST = t < ram_271ec ? t : ram_271ec;
		BuildSecondPageRecords();
	}
	return ram_271ea = i;
}

int FileIO_SelectWallpaperByIndex(int i)
{
	int r;
	int t;

	r = FileIO_ValidateModeAndRange(i);
	if (r == -1)
		return ram_272c8;
	if (r == 1) {
		t = (unsigned int)i / 10 * 10;
		ram_271ee = t;
		t += 9;
		FILE_LIST_LAST = t < ram_272ca ? t : ram_272ca;
		FileIO_ScanDirEntries();
	}
	return ram_272c8 = i;
}

extern char ram_25d74[];
extern char FileIO_EmptyVolumeName[];
extern char SearchLoadDefStr[];
extern int FileIO_SearchFile(char *path, char *vol);
extern char *GetVolumeLabel(void);
extern void FileIO_CopyString(char *, char *);
extern char *FileIO_SearchAndLoadFile(void);

char *FileIO_SearchAndLoadFile(void)
{
	char *v;

	if (FileIO_SearchFile(ram_25d74, FileIO_EmptyVolumeName) == 0) {
		v = GetVolumeLabel();
		if (v == 0 || FileIO_SearchFile(v, FileIO_EmptyVolumeName) == 0)
			v = SearchLoadDefStr;
		FileIO_CopyString(ram_25d74, v);
	}
	return ram_25d74;
}
