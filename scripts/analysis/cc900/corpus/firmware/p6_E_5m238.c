/* Phase 6, lane_p6 helper E, round 5, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): the FAT layer of
   v10 sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form a; p6_E_5m238b.c has the same
   names (b: `(char)` bit tests, the FAT data bytes indexed as `((unsigned char *)b)[(unsigned long)off + 26]`, no
   `register` on the sector variables).
   Fixes against rounds 3 and 4:
   - V4.23 gives a char array member an even size as well as an even start: round 3's `char p0[3]` took 4 bytes and
     moved every later field of the file record by 2 (the volume pointer read at +32, not +30).  Odd lone bytes are
     separate char members now.
   - SeqStep_FileIoCheck: for a compare of two memory operands V4.23 loads the left one when both are equally simple,
     so the two sector compares are written with the operand the ROM loads on the left.
   - The sector variables are `register long`: without it V4.23 kept the offset and value in QIZ / IZ and the sector in
     memory, where the ROM has the sector in XIZ. */
/* cc900-module: Fat_AllocateClusters Fat_CountContiguousClusters Fat_ReadEntry Fat_WriteDirEntry SeqStep_FileBufferFinal SeqStep_FileBufferSetup SeqStep_FileIoCheck SeqStep_FileSectorPopReturn */

struct buf;

typedef int __cdecl SECFN(long, struct buf *);

struct ops { char pad[20]; SECFN *wsec; };
struct dops { char pad[16]; SECFN *rsec; };
struct geom { char pad[12]; long l12; char pad1[32]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[2]; unsigned char vflags; char p3; char pad1[10]; struct ops *ops; char pad2[8];
	struct geom *geom; };
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

extern struct buf ram_2121a[];
extern unsigned char ram_3e3e0;
extern void *__cdecl Memset(void *, int, int);

int __cdecl SeqStep_FileBufferSetup(struct buf *b);
struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n);
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f);
int __cdecl Fat_WriteDirEntry(struct fil *f);
int __cdecl SeqStep_FileBufferFinal(struct fil *f);
void __cdecl SeqStep_FileSectorPopReturn(struct fil *f, unsigned int n, unsigned int val);

/* Returns a cache buffer holding sector sec of r's volume (b: a buffer to try first; flags bit 6: use b as it is,
   bit 5: no read, bit 2: retry on the other FAT copies).  0 on failure, the error in r->status.  The
   parameter b is reused as the hit. */
struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags)
{
	int i;
	struct buf *old;
	struct buf *p;
	unsigned int min;

	if (b != 0) {
		if (BITS(flags, 0x40)) {
			old = b;
use:
			if ((old->flags & 3) == 3 && (r->status = old->stat = SeqStep_FileBufferSetup(old)) != 0) {
				old->flags = 0;
				return old;
			}
			goto load;
		}
		if (b->vol == r->vol && b->sec == sec) {
			b->age += 2;
			b->flags |= flags;
			return b;
		}
	}
	if (sec == 1)
		i = 1;
	p = ram_2121a;
	b = 0;
	old = 0;
	min = 0x8000;
	for (i = 0; i < 10; i++, p++) {
		if (ram_3e3e0 != 0)
			p->age >>= 1;
		if (p->age != 0)
			p->age--;
		if (p->age < min && !(p->flags & 0x88)) {
			old = p;
			min = p->age;
		}
		if ((p->flags & 1) && r->vol == p->vol && sec == p->sec)
			b = p;
	}
	ram_3e3e0 = 0;
	if (b != 0) {
		b->age += 20;
		if (b->age & 0x8000)
			ram_3e3e0 = 1;
		b->flags |= flags;
		b->idx = r->unit;
		return b;
	}
	if (old != 0)
		goto use;
	r->status = 10;
fail:
	return 0;
load:
	old->sec = sec;
	old->vol = r->vol;
	old->idx = r->unit;
	old->drv = r->drv;
	old->stat = 0;
	if (!BITS(flags, 0x20)) {
		r->status = old->stat = r->dev->rsec(sec, old);
		if (old->stat != 0 && (r->vol->vflags & 2)) {
			r->status = old->stat = r->dev->rsec(sec, old);
			r->vol->vflags &= ~2;
		}
		i = 1;
		while (old->stat != 0 && BITS(flags, 4) && i++ < r->vol->geom->nfat) {
			sec += r->vol->geom->spf;
			r->status = old->stat = r->dev->rsec(sec, old);
		}
	}
	old->l8 = r->vol->geom->l12;
	if (old->stat == 0) {
		old->flags = (unsigned char)((flags & ~0x20) | 1);
		if ((old->age = 20) & 0x8000)
			ram_3e3e0 = 1;
		return old;
	}
	old->flags = 0;
	r->status = old->stat;
	goto fail;
}

/* FAT entry n of file f's volume: FAT12 when the volume's mask is 0xfff, else FAT16. */
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n)
{
	struct vrec *v;
	unsigned int off;
	unsigned int val;
	int fat16;
	unsigned long pos;
	register long sec;
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
	unsigned int off;
	struct vrec *v;
	unsigned long pos;
	register long sec;
	struct buf *b;

	v = f->vrec;
	if (v->mask == 0xfff) {
		pos = n * 3 / 2;
		off = pos & 0x1ff;
		sec = (pos >> 9) + v->fatstart;
		f->lastbuf = b = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 6);
		if (b == 0)
			return;
		if (BITS(n, 1)) {
			FATB(b, off) = (unsigned char)(((val & 0xf) << 4) | (FATB(b, off) & 0xf));
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
			} else
				FATB(b, off + 1) = (unsigned char)(((val >> 8) & 0xf) | (FATB(b, off + 1) & 0xf0));
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

/* Length of the contiguous run from the file's current cluster (+42), stored in +44 and returned. */
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

/* Finds n free clusters (searching up from the current one, then from 2) and links them to the file; zero: clear
   the last one's sectors.  0, 15 (disk full) or 10 / a buffer status on I/O failure. */
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n)
{
	unsigned int maxcl;
	unsigned int last;
	unsigned int prev;
	unsigned int run;
	struct vrec *q;
	register unsigned int cl;
	unsigned long s;
	register unsigned long sec;
	struct buf *b;

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
			run = prev = f->curclus = cl;
			f->cnt = 1;
		}
	}
	if (zero != 0) {
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
	struct vrec *v;
	unsigned char so;
	unsigned int cl;
	register unsigned long t;
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
			if (!(f->flags3 & 2))
				return 8;
			if ((r = Fat_AllocateClusters(f, 0, alloc)) == 0)
				goto join;
			return r;
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
