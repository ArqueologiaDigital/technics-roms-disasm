/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc_m267.c (2026-11-18-33-p6-r37)
   sha256 3a10b8186936812f561f6e28bde3a5cd4d91bcd6d926a21737b5508c3bf3a9ba (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
struct Path128 { char s[128]; };
extern FileP __cdecl FileOpen(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern struct Path128 FileIO_OpenWithMode_PathInit;
extern int FILE_ERROR;
extern FileP __near ram_7f44;
extern volatile int __near ram_7f48;
int FileIO_OpenWithMode(char *name, char *mode)
{
	struct Path128 path;

	path = FileIO_OpenWithMode_PathInit;
	FileIO_BuildFilePath(path.s, name);
	if ((ram_7f44 = FileOpen(path.s, mode)) == 0) {
		if (*mode == 'r') {
			ram_7f48 = -2;
			return -2;
		}
		if (*mode == 'w') {
			if (FILE_ERROR == 31) {
				ram_7f48 = -11;
				return -11;
			}
			ram_7f48 = -3;
			return -3;
		}
		ram_7f48 = -1;
		return -1;
	}
	ram_7f48 = 0;
	return ram_7f48;
}
