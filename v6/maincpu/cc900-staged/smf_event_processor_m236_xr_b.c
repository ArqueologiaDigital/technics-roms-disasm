/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct fd;
typedef int __cdecl IOFN(struct fd *, void *, unsigned int);
struct ops { char pad[4]; IOFN *read; char pad1[4]; IOFN *write; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };
extern int FILE_ERROR;
extern int __cdecl FileWrite(void *buf, int size, int n, struct fd *fp);

int __cdecl FileWrite(void *buf, int size, int n, struct fd *fp)
{
	if (fp == 0 || fp->open == 0) {
		FILE_ERROR = 0x11;
		return 0;
	}
	if (!(fp->open & 2)) {
		FILE_ERROR = 0x0d;
		return 0;
	}
	return fp->ops->write(fp, buf, size * n) / size;
}
