/* Phase 6, lane_p6 helper E, round 9, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form a; p6_E_9m238b.c and p6_E_9m238c.c
   have the same names.  Starting point: round 8 form b (p6_E_8m238b.c), which run 107 left one spot short in each.
   - Fat_TransferSectorsDirect (+17 at -Xr; the only difference in the whole function): after the call to
     Fat_MapFilePosToSector the ROM pops the arguments with `add xsp,14` and tests HL itself.  V4.23 writes that
     when a call's value goes straight into a test or into a plain assignment statement (run 100, p6_E_7m238's
     `b = SeqStep_FileIoCheck(...); if (b == 0)`); the assignment inside the condition, `(r = f()) != 0`, gave
     `lda xsp` and a copy to WA (and that is what the ROM's next routine, which calls Fat_MapFilePosToSector too,
     does).  So: `r = Fat_MapFilePosToSector(...);` as a statement, then `if (r != 0)` (form b: `if (r)`).
   - Fat_MapFilePosToSector (+82 at -Xr; one instruction): for `f->curclus = <first cluster>` the ROM loads f once
     and copies it to XBC; V4.23 loaded it twice from the cast of the char array (rounds 7 and 8).  An int is
     2-aligned (abi.md), so the word at +69 cannot be an int member of the file.  Here: the directory entry as a
     struct of its own that starts at the slot byte (+51), so that its first cluster lies at an even offset (+18)
     and its size at +20, read through a cast of &f->slot.  (Form b: a 2-byte struct copy; form c: the address of
     the source derived from the address of the destination.) */
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
/* an open file */
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4; unsigned char unit; int status; char p8[2];
	struct dops *dev; char p14[4]; struct vol2 *vol; unsigned long pos; unsigned long start; struct vrec *vrec;
	struct buf *cache; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx;
	unsigned int w48; unsigned char b50; unsigned char slot; unsigned char ent[24]; };
/* the file's directory entry, from its slot byte (file +51): name +1, attribute +13, time +14, first cluster +18,
   size +20 */
struct dent { unsigned char slot; char name[12]; unsigned char attr; char time[4]; unsigned int fcl;
	unsigned long size; };

#define FIL_FIRSTCLUS(f) (((struct dent *)&(f)->slot)->fcl)

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
		f->curclus = FIL_FIRSTCLUS(f);
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
	unsigned int r;

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
	f->cnt -= r / v->clbytes;
	f->cache->flags = 0;
	if (f->cache->stat == 35)
		f->cache->stat = 0;
	return r;
}
