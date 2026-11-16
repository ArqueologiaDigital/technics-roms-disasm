/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Fat_AllocateClusters Fat_CountContiguousClusters Fat_ReadEntry Fat_WriteDirEntry SeqStep_FileBufferFinal SeqStep_FileBufferSetup SeqStep_FileIoCheck SeqStep_FileSectorPopReturn */   /* scripts/analysis/cc900/module_calls.py v10 */

struct buf;
typedef int __cdecl SECFN(long, struct buf *);
struct ops { char pad[20]; SECFN *wsec; };
struct geom { char pad[12]; long l12; char pad1[32]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[2]; unsigned char vflags; char p3; char pad1[10]; struct ops *ops; char pad2[8];
	struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4[14]; struct vol2 *vol; unsigned long pos;
	unsigned long start; struct vrec *vrec; char p34[4]; struct buf *lastbuf; unsigned int curclus; unsigned int cnt;
	unsigned int curidx; };
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f);
extern unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
extern unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f);

unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f)
{
	unsigned int c;
	unsigned int last;
	unsigned int n;

	last = f->vrec->mask - 8;
	c = f->curclus;
	if (c == 0) {
		f->cnt = 0;
		return 0;
	}
	f->cnt = 1;
	while ((n = Fat_ReadEntry(f, c)) <= last) {
		if (++c != n)
			break;
		f->cnt++;
	}
	return f->cnt;
}
