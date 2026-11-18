/* Phase 6, lane_p6 helper K, round 3, module 267, form b: FileIO_ReadBlock (+1 in run 2026-11-18-12-p6-r35).
   At -O3 the goto-only error code became a register and the err < 0 test vanished; the ROM keeps both.  Written
   without gotos (V4.23 should thread the constant error paths straight to the cell update), the count n used as
   the parameter itself (the ROM tests XBC before spilling it to the slot under buf), and the read count as a long
   local (one `exts xhl`). */

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
	long r;

	err = 0;
	total = 0;
	if (ram_7f44 != 0) {
		while (n > 0) {
			chunk = n < 0x7fff ? n : 0x7fff;
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
			n -= chunk;
		}
	} else
		err = -100;
	if (err < 0) {
		ram_7f48 = ram_7f48 < 0 ? ram_7f48 : err;
		total = err;
	}
	return total;
}
