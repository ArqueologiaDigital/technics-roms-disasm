/* Phase 6, lane_p6 helper E, round 6, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form a; p6_E_6m238b.c has the same name
   (b: the cluster index converted implicitly, and the sector count divided in one statement).
   Fat_TransferSectorsDirect moves whole sectors of a file read / write straight between the caller's buffer and the
   disk, borrowing a cache entry's data pointer (+12) and sector count (+16).
   The structs are rounds 3-5's with the fields this routine adds (file +6 status, +10 device, +34 cache entry; cache
   entry +12 data pointer, +16 count); char arrays keep even sizes. */
/* cc900-module: Fat_MapFilePosToSector SeqStep_FileIoCheck */

struct buf;

typedef int __cdecl SECFN(long, struct buf *);

struct dops { char pad[16]; SECFN *rsec; SECFN *wsec; };
struct vol;
struct buf { struct vol *vol; long sec; long l8; unsigned char *dptr; unsigned int cnt; char p18[2]; int stat;
	unsigned char flags; unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct rq;
/* the volume record a file points at (+30) */
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
/* an open file */
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4; unsigned char unit; int status; char p8[2];
	struct dops *dev; char p14[4]; struct vol2 *vol; unsigned long pos; unsigned long start; struct vrec *vrec;
	struct buf *cache; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx; };

extern int FILE_ERROR;

struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
int __cdecl Fat_MapFilePosToSector(struct fil *f, int alloc, unsigned long *psec, unsigned int *pcnt);

unsigned int __cdecl Fat_TransferSectorsDirect(struct fil *f, unsigned char *p, int count, int isread)
{
	unsigned int k;
	struct vrec *v;
	unsigned int run;
	unsigned long sec;
	int r;

	if (count == 0)
		return 0;
	v = f->vrec;
	k = (unsigned int)(f->pos / v->clbytes);
	if ((r = Fat_MapFilePosToSector(f, (count + f->pos + v->clbytes - 1) / v->clbytes - k, &sec, &run)) != 0) {
		f->status = FILE_ERROR = (char)r;
		return 0;
	}
	if (f->cache != 0) {
		if ((f->cache->flags & 3) != 3)
			goto use;
		f->cache->flags &= ~8;
	}
	if ((f->cache = SeqStep_FileIoCheck((struct rq *)f, sec, 0, 0x28)) == 0) {
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
