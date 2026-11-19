/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_5m268a.c (2026-11-19-37-p6-r47)
   sha256 a0a67259421a771e85ad9ededdaf09d9939aae46ec0b3b032049680ce383b562 (tar-sha256); compiled at -Xr
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
		v = GetVolumeLabel();
		if (v == 0 || FileIO_SearchFile(v, FileIO_EmptyVolumeName) == 0)
			v = SearchLoadDefStr;
		FileIO_CopyString(ram_25d74, v);
	}
	return ram_25d74;
}
