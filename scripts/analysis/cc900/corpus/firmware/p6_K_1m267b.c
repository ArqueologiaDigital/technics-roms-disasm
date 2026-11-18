/* Phase 6, lane_p6 helper K, round 1, module 267, form b of p6_K_1m267a.c: FileIO_OpenWithMode returning
   `ram_7f48 = K` as one expression everywhere; FileIO_ReadBlock with the chunk ternary spelled the other way round
   (`left >= 0x7fff ? 0x7fff : left`, the ROM loads 0x7fff first) and the short read written as the else branch. */

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
			chunk = left >= 0x7fff ? 0x7fff : left;
			r = FileRead(buf, 1, chunk, ram_7f44);
			if (r == chunk) {
				total += r;
				buf += chunk;
				left -= chunk;
			} else {
				if (ram_7f44->flag & 0x8000)
					total += r;
				else {
					err = -2;
					goto fail;
				}
				break;
			}
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
