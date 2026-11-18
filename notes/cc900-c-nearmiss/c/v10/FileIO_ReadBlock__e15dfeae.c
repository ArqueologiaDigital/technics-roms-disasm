/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_3m267b.c (2026-11-18-28-p6-r36)
   sha256 e15dfeae8696094fe6051f1efcb1be1052926fbc5f61620372f6019a3d72232e (tar-sha256); compiled at -O3 -Xr */
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
