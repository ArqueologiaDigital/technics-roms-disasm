/* Phase 6, lane_p6 helper E, round 7, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form b; p6_E_7m238.c (form a) has the same
   names.
   Round 5 matched SeqStep_FileIoCheck and Fat_CountContiguousClusters; this round refines the other four.
   - XIZ.  V4.23 gives XIZ (the one callee-saved register) to the variables it counts as most used, and ignores
     `register`.  Round 5 gave it to the offset and value / the entry number (QIZ + IZ), where the ROM keeps the
     sector there and the others on the stack.  Here those others are `volatile`: in -Xr code every access to them
     is a load or store anyway, and volatile keeps them out of registers (form b: only the offset / value).
   - The 12-bit merges go through an unsigned char temporary: the ROM computes the new byte first, moves it to C,
     then computes the address again; V4.23 computed the address first for the direct assignment.
   - Fat_AllocateClusters: `f->curclus = cl; prev = cl; run = cl;` as three statements (the ROM stores IZ three times;
     the assignment chain reloads); form b also puts the loop's and the zeroing's locals in their own blocks.
   - Fat_MapFilePosToSector: locals declared in the ROM's slot order (V4.23 gives the first-declared scalar the lowest
     slot), and the writable test before the `return 8`. */
/* cc900-module: Fat_AllocateClusters Fat_CountContiguousClusters Fat_ReadEntry Fat_WriteDirEntry SeqStep_FileBufferFinal SeqStep_FileIoCheck SeqStep_FileSectorPopReturn */

struct buf;
struct vol;
struct dops;

struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
/* the request: the open file / directory search record */
struct rq { unsigned char drv; char p1; char pad[2]; char p4; unsigned char unit; int status; char pad1[2];
	struct dops *dev; char pad2[4]; struct vol *vol; };
/* the volume record a file points at (+30); a file's +18 points at a record whose +26 is the same kind */
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
/* an open file */
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4[14]; struct vol2 *vol; unsigned long pos;
	unsigned long start; struct vrec *vrec; char p34[4]; struct buf *lastbuf; unsigned int curclus; unsigned int cnt;
	unsigned int curidx; };

#define FIL_FIRSTCLUS(f) (*(unsigned int *)((char *)(f) + 69))
#define FATB(b, i) (*((unsigned long)(i) + 26 + (unsigned char *)(b)))
#define BITS(n, m) ((unsigned char)(n) & (m))

extern void *__cdecl Memset(void *, int, int);

struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n);
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f);
int __cdecl Fat_WriteDirEntry(struct fil *f);
int __cdecl SeqStep_FileBufferFinal(struct fil *f);
void __cdecl SeqStep_FileSectorPopReturn(struct fil *f, unsigned int n, unsigned int val);

/* FAT entry n of file f's volume: FAT12 when the volume's mask is 0xfff, else FAT16. */
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n)
{
	struct vrec *v;
	volatile unsigned int off;
	volatile unsigned int val;
	int fat16;
	unsigned long pos;
	long sec;
	struct buf *b;

	fat16 = 0;
	if ((v = f->vrec)->mask == 0xfff)
		pos = n * 3 / 2;
	else {
		fat16 = 1;
		pos = (unsigned long)n * 2;
	}
	off = pos & 0x1ff;
	sec = (pos >> 9) + v->fatstart;
	f->lastbuf = b = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 4);
	if (b == 0)
		return v->mask - 8;
	val = FATB(b, off);
	if (off == 0x1ff) {
		b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 4);
		if (b == 0)
			return v->mask - 8;
		val += (unsigned int)b->data[0] << 8;
	} else
		val += (unsigned int)FATB(b, off + 1) << 8;
	if (fat16)
		return val;
	if (BITS(n, 1))
		return val >> 4;
	return val & 0xfff;
}

/* Stores val as FAT entry n of f's volume (FAT12 when the mask is 0xfff, else FAT16). */
void __cdecl SeqStep_FileSectorPopReturn(struct fil *f, unsigned int n, unsigned int val)
{
	volatile unsigned int off;
	struct vrec *v;
	unsigned long pos;
	long sec;
	struct buf *b;
	unsigned char t;

	v = f->vrec;
	if (v->mask == 0xfff) {
		pos = n * 3 / 2;
		off = pos & 0x1ff;
		sec = (pos >> 9) + v->fatstart;
		f->lastbuf = b = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 6);
		if (b == 0)
			return;
		if (BITS(n, 1)) {
			t = ((val & 0xf) << 4) | (FATB(b, off) & 0xf);
			FATB(b, off) = t;
			if (off == 0x1ff) {
				b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 6);
				if (b == 0)
					return;
				b->data[0] = val >> 4;
			} else
				FATB(b, off + 1) = val >> 4;
		} else {
			FATB(b, off) = (unsigned char)(val & 0xff);
			if (off == 0x1ff) {
				b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 6);
				if (b == 0)
					return;
				b->data[0] = (unsigned char)(((val >> 8) & 0xf) | (b->data[0] & 0xf0));
			} else {
				t = ((val >> 8) & 0xf) | (FATB(b, off + 1) & 0xf0);
				FATB(b, off + 1) = t;
			}
		}
	} else {
		pos = (unsigned long)n * 2;
		off = pos & 0x1ff;
		sec = (pos >> 9) + v->fatstart;
		f->lastbuf = b = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 6);
		if (b == 0)
			return;
		FATB(b, off) = (unsigned char)(val & 0xff);
		FATB(b, off + 1) = val >> 8;
	}
}

/* Finds n free clusters (searching up from the current one, then from 2) and links them to the file; zero: clear
   the last one's sectors.  0, 15 (disk full) or 10 / a buffer status on I/O failure. */
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n)
{
	unsigned int maxcl;
	unsigned int last;
	struct vrec *q;
	unsigned int cl;

	{
	unsigned int prev;
	unsigned int run;

	prev = 0;
	run = 0;
	q = f->vol->vrec;
	maxcl = f->vrec->maxcl;
	last = f->curclus;
	while (n-- != 0) {
		cl = last + 1 < 2 ? 2 : last + 1;
		for (; cl <= maxcl; cl++)
			if (Fat_ReadEntry(f, cl) == 0)
				goto found;
		for (cl = 2; cl < last; cl++)
			if (Fat_ReadEntry(f, cl) == 0)
				goto found;
		Fat_WriteDirEntry(f);
		SeqStep_FileBufferFinal(f);
		return 15;
found:
		SeqStep_FileSectorPopReturn(f, cl, f->vrec->mask);
		if (FIL_FIRSTCLUS(f) == 0)
			FIL_FIRSTCLUS(f) = cl;
		else {
			SeqStep_FileSectorPopReturn(f, last, cl);
			if (prev == 0)
				f->curidx++;
		}
		last = cl;
		if (++run == cl)
			f->cnt++;
		else
			run = 0;
		if (prev == 0) {
			f->curclus = cl;
			prev = cl;
			run = cl;
			f->cnt = 1;
		}
	}
	}
	if (zero != 0) {
		unsigned long s;
		unsigned long sec;
		struct buf *b;

		s = q->datastart + q->spc * (cl - 2);
		for (sec = s; sec < s + q->spc; sec++) {
			if ((b = SeqStep_FileIoCheck((struct rq *)f, sec, 0, 0x22)) == 0)
				return 10;
			if (b->stat != 0)
				return b->stat;
			Memset(b->data, 0, 512);
		}
	}
	return 0;
}

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
