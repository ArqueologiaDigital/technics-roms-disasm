/* Phase 6, lane_p6 helper K, round 1, module 267 (demo/file_demo_proc.s), form a.
   FileIO_OpenWithMode: the 128-byte path prefix FileIO_OpenWithMode_PathInit copied by value (the `ld xiy, Sym; ldirw`
   struct copy FileIO_CompareFiles already matches with), the name appended by FileIO_BuildFilePath, FileOpen's
   handle kept in the __near cell 0x7f44 and an error code in the __near cell 0x7f48.  The failure returns store and
   return a constant; the success return reloads the cell (form a: `ram_7f48 = 0; return ram_7f48;`).
   FileIO_ReadBlock: reads n bytes in chunks of at most 0x7fff with FileRead; on a short read the handle's bit 15
   (end of file) decides between keeping the count and error -2; no handle gives -100.  On an error the cell 0x7f48
   keeps an older negative code (ternary), and the error is returned as a long. */

struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
struct Path128 { char s[128]; };
extern FileP __cdecl FileOpen(char *, char *);
extern int __cdecl FileRead(char *, int, int, FileP);
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

long FileIO_ReadBlock(char *buf, long n)
{
	int err;
	long total;
	long chunk;
	long left;
	int r;

	err = 0;
	total = 0;
	if (ram_7f44 != 0) {
		left = n;
		while (left > 0) {
			chunk = left < 0x7fff ? left : 0x7fff;
			r = FileRead(buf, 1, chunk, ram_7f44);
			if (r != chunk) {
				if (ram_7f44->flag & 0x8000)
					total += r;
				else {
					err = -2;
					goto fail;
				}
				break;
			}
			total += r;
			buf += chunk;
			left -= chunk;
		}
	} else {
		err = -100;
		goto fail;
	}
	if (err < 0) {
fail:
		ram_7f48 = ram_7f48 < 0 ? ram_7f48 : err;
		total = err;
	}
	return total;
}
