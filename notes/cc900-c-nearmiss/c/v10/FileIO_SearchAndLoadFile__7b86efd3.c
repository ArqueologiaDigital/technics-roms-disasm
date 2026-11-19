/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_6m268a.c (2026-11-19-49-p6-r49)
   sha256 7b86efd38ae6a5b227ca1956ccc2c76e98d8ad941db6b61377977799ab17ea91 (tar-sha256); compiled at -Xr
   cc900-name: SearchLoadDefStr=SearchLoad_DefaultVolume_Str_Under_Under_Under_Under */
extern char ram_25d74[];
extern char FileIO_EmptyVolumeName[];
extern char SearchLoadDefStr[];
extern int FileIO_SearchFile(char *path, char *vol);
extern char *GetVolumeLabel(void);
extern void FileIO_CopyString(char *, char *);
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
