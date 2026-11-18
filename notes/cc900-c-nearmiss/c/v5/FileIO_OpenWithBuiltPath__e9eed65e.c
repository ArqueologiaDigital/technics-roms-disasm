/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m268.c (2026-11-18-28-p6-r36)
   sha256 e9eed65ef681a08cce01e360fb726e3f522642687d0c587c0c20dbd4db8730f4 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void FileIO_CopyString(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern int FileIO_OpenWithMode(char *, char *);
int FileIO_OpenWithBuiltPath(char *name, char *mode)
{
	char path[140];

	FileIO_CopyString(path, (char *)0x272d2);
	FileIO_BuildFilePath(path, (char *)0x272f2);
	FileIO_BuildFilePath(path, name);
	return FileIO_OpenWithMode(path, mode);
}
