/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_3m267c.c (2026-11-18-28-p6-r36)
   sha256 1efaad1a74c481631fd05d695c84bd7f79b3c689f209b716e6d960fe5a898d69 (tar-sha256); compiled at -O3 -Xr */
struct FileS { char pad[6]; int flag; };
typedef struct FileS *FileP;
extern int __cdecl FileRead(char *, int, int, FileP);
extern FileP __near ram_7f44;
extern int __near ram_7f48;
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
				else
					err = -2;
				break;
			}
			total += r;
			buf += chunk;
			left -= chunk;
		}
	} else
		err = -100;
	if (err < 0) {
		ram_7f48 = ram_7f48 < 0 ? ram_7f48 : err;
		total = err;
	}
	return total;
}
