/* Phase 6, lane_p6 helper K, round 3, module 267 (demo/file_demo_proc.s), form a: one-spot refinement of round 1
   (run 2026-11-18-12-p6-r35).  FileIO_OpenWithMode (+64): V4.23 folds `ram_7f48 = 0; return ram_7f48;` into a
   constant at every option set; the ROM reloads the cell, so the cell is declared volatile here (the failure paths
   keep their constant returns).  Alone in its file: FileIO_ReadBlock reads the cell once, so it must not see it
   volatile (forms b / c). */

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
