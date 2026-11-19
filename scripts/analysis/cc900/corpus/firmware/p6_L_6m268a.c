/* Phase 6, lane_p6 helper L, round 6, form a: module 268.  Retry of FileIO_SearchAndLoadFile (r47 Xr +17): the ROM
   takes the volume label through XWA (`ld xwa,xhl; ld xiz,xwa; or xwa,xwa`), i.e. tests the value of the
   assignment: `(v = GetVolumeLabel()) == 0`. */
/* cc900-module: FileIO_CopyString FileIO_SearchFile */   /* scripts/analysis/cc900/module_calls.py v10 */

/* cc900-name: SearchLoadDefStr=SearchLoad_DefaultVolume_Str_Under_Under_Under_Under */
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
		if ((v = GetVolumeLabel()) == 0 || FileIO_SearchFile(v, FileIO_EmptyVolumeName) == 0)
			v = SearchLoadDefStr;
		FileIO_CopyString(ram_25d74, v);
	}
	return ram_25d74;
}
