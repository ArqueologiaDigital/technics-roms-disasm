/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
struct Path128 { char s[128]; };
extern FileP __cdecl FileOpen(char *, char *);
extern void FileIO_BuildFilePath(char *, char *);
extern struct Path128 FileIO_OpenWithMode_PathInit;
extern int FILE_ERROR;
extern FileP __near ram_7f44;
extern volatile int __near ram_7f48;
extern int FileIO_OpenWithMode(char *name, char *mode);

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
