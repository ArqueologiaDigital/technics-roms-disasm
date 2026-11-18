/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m267a.c (2026-11-18-12-p6-r35)
   sha256 a5679b78dd09f8b928d7e450802471720fb9e4762553e3fea337aa323ead9293 (tar-sha256); compiled at -O3 -Xr */
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
