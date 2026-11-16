/* Phase 6, lane_p6 helper E, round 10, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form a; p6_E_10m238b.c and
   p6_E_10m238c.c have the same names.  Starting point: round 9 (p6_E_9m238*.c), one spot short in each.
   - Fat_TransferSectorsDirect (+17 at -Xr in run 118 too): V4.23 still pops with `lda xsp` and copies HL to WA
     before `cp`; the ROM writes `add xsp,14` and `cp hl,0`.  In every V4.23 listing that writes `add xsp` the value is
     tested in the register it came back in (run 100's `b = SeqStep_FileIoCheck(...)`, lane_hd's `if (MemCmp(...))`).
     Ours was converted first: the callee returns int and r was unsigned.  Here r is an int (form a: statement form;
     form c: `(r = ...) != 0`); form b keeps r unsigned and declares Fat_MapFilePosToSector unsigned instead.
   - Fat_MapFilePosToSector (+82; one instruction): `f->curclus = <the word at f+69>`, where the ROM loads f into XWA
     once and copies it to XBC for the store (V4.23 does that when it computes a store address as an expression,
     run 2026-11-15-8's stptr probes).  Form a writes the destination as an address expression,
     `*(unsigned int *)((char *)f + 42)`; form b `*(unsigned int *)&f->curclus`; form c reads the source as
     `((unsigned int *)(f->ent + 1))[8]`.  Run 118's forms (directory-entry struct, struct copy, address from
     &f->curclus) all computed the source address first and reloaded f. */
/* cc900-module: Fat_AllocateClusters Fat_CountContiguousClusters Fat_MapFilePosToSector Fat_ReadEntry SeqStep_FileIoCheck */

struct buf;
struct vol;

typedef int __cdecl SECFN(long, struct buf *);

struct dops { char pad[16]; SECFN *rsec; SECFN *wsec; };
struct buf { struct vol *vol; long sec; long l8; unsigned char *dptr; unsigned int cnt; char p18[2]; int stat;
	unsigned char flags; unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
/* the volume record a file points at (+30); a file's +18 points at a record whose +26 is the same kind */
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
/* an open file; its directory entry (slot +51, name +52, attribute +64, time +65, first cluster +69, size +71) */
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4; unsigned char unit; int status; char p8[2];
	struct dops *dev; char p14[4]; struct vol2 *vol; unsigned long pos; unsigned long start; struct vrec *vrec;
	struct buf *cache; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx;
	unsigned int w48; unsigned char b50; unsigned char slot; unsigned char ent[24]; };

extern int FILE_ERROR;

struct buf *__cdecl SeqStep_FileIoCheck(struct fil *r, long sec, struct buf *b, int flags);
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n);
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f);
int __cdecl Fat_MapFilePosToSector(struct fil *f, int alloc, unsigned long *psec, unsigned int *pcnt);

/* Maps f's position to an absolute sector (*psec) and the sectors that follow it contiguously (*pcnt); alloc:
   clusters to add when the chain ends on a writable file.  0, 39 (bad cluster), 8 (end of a read-only chain) or
   Fat_AllocateClusters' error. */
int __cdecl Fat_MapFilePosToSector(struct fil *f, int alloc, unsigned long *psec, unsigned int *pcnt)
{
	unsigned int cl;
	unsigned char so;
	struct vrec *v;
	unsigned long t;
	unsigned int n;
	int r;

	v = f->vrec;
	if (f->start == 0) {
		*psec = v->rootstart + f->pos / v->bps;
		*pcnt = v->rootsecs - (*psec - v->rootstart);
		return 0;
	}
	cl = (unsigned int)(f->pos / v->clbytes);
	t = f->pos % v->clbytes;
	so = t / v->bps;
	if (f->curidx == cl) {
		if (f->curclus == 0 && (f->flags3 & 2)) {
			if ((r = Fat_AllocateClusters(f, 0, alloc)) == 0)
				goto join;
			return r;
		}
		if (f->cnt == 0)
			Fat_CountContiguousClusters(f);
		goto join;
	}
	if (f->curidx > cl) {
		*(unsigned int *)((char *)f + 42) = *(unsigned int *)(f->ent + 17);
		f->curidx = 0;
	}
	n = f->curclus;
	while (f->curidx < cl) {
		n = Fat_ReadEntry(f, n);
		if (v->mask - 8 == n)
			return 39;
		if (n > v->mask - 8) {
			if (f->flags3 & 2) {
				if ((r = Fat_AllocateClusters(f, 0, alloc)) == 0)
					goto join;
				return r;
			}
			return 8;
		}
		f->curclus = n;
		f->curidx++;
	}
	Fat_CountContiguousClusters(f);
join:
	*psec = so + v->datastart;
	*psec += v->spc * (f->curclus - 2);
	*pcnt = v->spc * f->cnt - so;
	return 0;
}

/* Moves whole sectors of a file read (isread) or write straight between p and the disk, borrowing a cache entry's
   data pointer (+12) and sector count (+16).  The bytes moved, or 0 with the error in f->status and FILE_ERROR. */
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
