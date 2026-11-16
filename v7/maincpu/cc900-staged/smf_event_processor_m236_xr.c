/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

struct fd;
typedef int __cdecl CLOSEFN(struct fd *);
typedef int __cdecl CTLFN(struct fd *, int, long);
struct ops { char pad[20]; CLOSEFN *close; char pad1[12]; CTLFN *ctl; };
struct fd { char p0[4]; unsigned char open; unsigned char slot; char p6[8]; struct ops *ops; };
extern int FILE_ERROR;
extern struct fd *ram_210b4[];
extern unsigned char ram_210f4;
extern int __cdecl SeqStep_FreeMemory(void *p);
extern void __cdecl SeqStep_FileNopA(int n);
extern void __cdecl SeqStep_FileNopB(void);
extern int __cdecl SeqStep_FileCloseInner(struct fd *h);

int __cdecl SeqStep_FileCloseInner(struct fd *h)
{
	int r;
	int slot;
	int fr;

	if (h == 0 || h->open == 0 || ram_210b4[h->slot] != h) {
		FILE_ERROR = 0x11;
		return -1;
	}
	r = h->ops->close(h);
	if (r != 0)
		FILE_ERROR = (char)r;
	ram_210f4++;
	ram_210b4[h->slot] = 0;
	slot = h->slot;
	fr = SeqStep_FreeMemory(h);
	if (fr != 0 && r == 0)
		FILE_ERROR = 0x26;
	SeqStep_FileNopA(slot + 100);
	SeqStep_FileNopB();
	if (r != 0 || fr != 0)
		return -1;
	return 0;
}
