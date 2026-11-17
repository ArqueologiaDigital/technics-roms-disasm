/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Fat_AllocateClusters Fat_CountContiguousClusters Fat_MapFilePosToSector Fat_ReadEntry SeqStep_FileIoCheck */   /* scripts/analysis/cc900/module_calls.py v10 */

struct buf;
struct vol;
typedef int __cdecl SECFN(long, struct buf *);
struct dops { char pad[16]; SECFN *rsec; SECFN *wsec; };
struct buf { struct vol *vol; long sec; long l8; unsigned char *dptr; unsigned int cnt; char p18[2]; int stat;
	unsigned char flags; unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4; unsigned char unit; int status; char p8[2];
	struct dops *dev; char p14[4]; struct vol2 *vol; unsigned long pos; unsigned long start; struct vrec *vrec;
	struct buf *cache; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx;
	unsigned int w48; unsigned char b50; unsigned char slot; unsigned char ent[24]; };
extern int FILE_ERROR;
struct buf *__cdecl SeqStep_FileIoCheck(struct fil *r, long sec, struct buf *b, int flags);
int __cdecl Fat_MapFilePosToSector(struct fil *f, int alloc, unsigned long *psec, unsigned int *pcnt);
extern int __cdecl Fat_MapFilePosToSector(struct fil *f, int alloc, unsigned long *psec, unsigned int *pcnt);
extern unsigned int __cdecl Fat_TransferSectorsDirect(struct fil *f, unsigned char *p, int count, int isread);

unsigned int __cdecl Fat_TransferSectorsDirect(struct fil *f, unsigned char *p, int count, int isread)
{
	unsigned int k;
	struct vrec *v;
	unsigned long sec;
	unsigned int run;
	int m;
	int r;

	if (count == 0)
		return 0;
	v = f->vrec;
	k = (unsigned int)(f->pos / v->clbytes);
	m = (count + f->pos + v->clbytes - 1) / v->clbytes - k;
	r = Fat_MapFilePosToSector(f, m, &sec, &run);
	if (r != 0) {
		f->status = FILE_ERROR = (char)r;
		return 0;
	}
	if (f->cache != 0) {
		if ((f->cache->flags & 3) != 3)
			goto use;
		f->cache->flags &= ~8;
	}
	if ((f->cache = SeqStep_FileIoCheck(f, sec, 0, 0x28)) == 0) {
		f->status = 10;
		FILE_ERROR = 10;
		return 0;
	}
use:
	f->cache->dptr = p;
	k = count;
	k = k / v->bps;
	f->cache->cnt = k < run ? k : run;
	k = f->cache->cnt;
	if (isread)
		f->status = f->cache->stat = f->dev->rsec(sec, f->cache);
	else
		f->status = f->cache->stat = f->dev->wsec(sec, f->cache);
	f->cache->flags &= ~8;
	f->cache->dptr = 0;
	if (f->cache->stat != 0)
		r = 0;
	else
		r = k * v->bps;
	f->cnt -= (unsigned int)r / v->clbytes;
	f->cache->flags = 0;
	if (f->cache->stat == 35)
		f->cache->stat = 0;
	return r;
}
