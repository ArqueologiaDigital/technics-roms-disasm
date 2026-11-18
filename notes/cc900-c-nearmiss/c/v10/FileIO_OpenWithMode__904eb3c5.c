/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m267b.c (2026-11-18-12-p6-r35)
   sha256 904eb3c540e1df1cff0f2a14b3beba9b0659882fca3637a5cd35f132a44eea47 (tar-sha256); compiled at -O3 -Xr */
struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
struct Path128 { char s[128]; };
extern FileP __cdecl FileOpen(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern struct Path128 FileIO_OpenWithMode_PathInit;
extern int FILE_ERROR;
extern FileP __near ram_7f44;
extern int __near ram_7f48;
int FileIO_OpenWithMode(char *name, char *mode)
{
	struct Path128 path;

	path = FileIO_OpenWithMode_PathInit;
	FileIO_BuildFilePath(path.s, name);
	ram_7f44 = FileOpen(path.s, mode);
	if (ram_7f44 == 0) {
		if (*mode == 'r')
			return ram_7f48 = -2;
		if (*mode == 'w') {
			if (FILE_ERROR == 31)
				return ram_7f48 = -11;
			return ram_7f48 = -3;
		}
		return ram_7f48 = -1;
	}
	return ram_7f48 = 0;
}
