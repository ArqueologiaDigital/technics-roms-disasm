/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_E_8m238.c (2026-11-16-107-p6-r21)
   sha256 c1834ef0a72c2396e0f7fc3c628945cd3d22bd630a6e60e8ed28ccdce15b3058 (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper E, round 8, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form a; p6_E_8m238b.c has the same names.
   Run 100 (rounds 6 / 7), compared instruction by instruction:
   - Fat_MapFilePosToSector differed in one instruction: for `f->curclus = <word at f+69>` the ROM loads f once and
     copies it (`ld xbc,xwa`), V4.23 loaded it twice through the cast `(char *)f + 69`.  The word at +69 is now an
     element of the file's in-memory directory entry, a char array at +52 (slot +51, name +52, attribute +64, time
     +65, first cluster +69, size +71: Fat_CreateDirEntry's fields), read as `*(unsigned int *)&f->ent[17]`
     (form b: `f->ent + 17`).
   - Fat_TransferSectorsDirect: the ROM computes the cluster count argument before pushing &run / &sec (now through a
     local, lane_sub's (b)); the address-taken locals are declared sec first (V4.23 gave the later one the lower
     slot); the result is unsigned and tested as it comes back (`add xsp` + `cp hl`); and SeqStep_FileIoCheck is
     declared with the file type, because the cast made V4.23 push f through XWA where the ROM pushes XIZ.
     Form b: the count local is an int.
   Not retried: Fat_ReadEntry, SeqStep_FileSectorPopReturn, Fat_AllocateClusters.  V4.23 gives XIZ to the
   offset / value / entry number (QIZ + IZ) and ignores both `register` and `volatile` (run 100), where the ROM keeps
   the sector in XIZ; and it does not reuse XIZ for the sector after the cluster number dies. */
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

#define FIL_FIRSTCLUS(f) (*(unsigned int *)&(f)->ent[17])

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
	unsigned int m;
	unsigned int r;

	if (count == 0)
		return 0;
	v = f->vrec;
	k = (unsigned int)(f->pos / v->clbytes);
	m = (count + f->pos + v->clbytes - 1) / v->clbytes - k;
	if ((r = Fat_MapFilePosToSector(f, m, &sec, &run)) != 0) {
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
