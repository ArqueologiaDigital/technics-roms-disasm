/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m268a.c (2026-11-18-12-p6-r35)
   sha256 1e8938a3a02bfb49c44cccf1d3938449ae5e05a9791933787b725acf7f65fb37 (tar-sha256); compiled at -O3 -XS -Xr */
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
