/* Phase 6, lane_p6 helper K, round 3, module 267, form c: FileIO_ReadBlock as form b but keeping round 1's local
   copy `left` of the count (frame: err, total, chunk, left, then buf) and the int read count. */

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
