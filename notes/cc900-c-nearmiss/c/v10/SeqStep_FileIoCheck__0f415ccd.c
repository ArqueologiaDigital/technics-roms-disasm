/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_E_3m238b.c (2026-11-16-87-p6-r15)
   sha256 0f415ccd55ef56527ce6785e5bcb154e3d099f97baf4db6a384776cd4df4df9f (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper E, round 3, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): the FAT sector
   cache and cluster mapping of v10 sequencer/smf_event_processor.s (built -Xr), under the firmware names.
   Form b; p6_E_3m238.c (form a) has the same names.  Here: `(char)flags` bit tests, Fat_ReadEntry's data bytes
   addressed as integers and its assignment chain reversed, Fat_MapFilePosToSector's operand orders swapped.
   Struct layouts: V4.23 starts every array member at an even offset (round 2's pad[11] after a char moved the next
   field by one), so odd single bytes are separate char members.  The file's word at +69 is read through a cast. */
/* cc900-module: Fat_AllocateClusters Fat_CountContiguousClusters Fat_ReadEntry SeqStep_FileBufferSetup SeqStep_FileIoCheck */

struct buf;

typedef int __cdecl SECFN(long, struct buf *);

struct ops { char pad[20]; SECFN *wsec; };
struct dops { char pad[16]; SECFN *rsec; };
struct geom { char pad[12]; long l12; char pad1[32]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[2]; unsigned char vflags; char p3; char pad1[10]; struct ops *ops; char pad2[8];
	struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct hnd { char pad[6]; int w6; };
/* the request: the open file / directory search record */
struct rq { unsigned char drv; char p1; char pad[2]; char p4; unsigned char unit; int status; char pad1[2];
	struct dops *dev; char pad2[4]; struct vol *vol; };
/* the volume record a file points at (+30) */
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; };
/* an open file */
struct fil { char p0[3]; unsigned char flags3; char p4[18]; unsigned long pos; unsigned long start; struct vrec *vrec;
	char p34[4]; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx; };

#define FIL_FIRSTCLUS(f) (*(unsigned int *)((char *)(f) + 69))

extern struct hnd *ram_210b4[];
extern struct buf ram_2121a[];
extern unsigned char ram_3e3e0;

int __cdecl SeqStep_FileBufferSetup(struct buf *b);
struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_AllocateClusters(struct fil *f, int a, int n);
int __cdecl Fat_CountContiguousClusters(struct fil *f);

int __cdecl SeqStep_FileBufferSetup(struct buf *b)
{
	int i;
	long sec;
	struct buf *p;

	ram_210b4[b->idx]->w6 = b->stat = b->vol->ops->wsec(b->sec, b);
	b->flags &= ~2;
	if (b->flags & 4) {
		sec = b->sec;
		for (i = 1; i < b->vol->geom->nfat; i++) {
			sec += b->vol->geom->spf;
			ram_210b4[b->idx]->w6 = b->stat |= b->vol->ops->wsec(sec, b);
		}
	}
	if (b->stat == 0)
		return 0;
	if (b->stat == 0x1f) {
		b->flags &= ~1;
		p = ram_2121a;
		for (i = 0; i < 10; i++, p++) {
			if ((p->flags & 2) && p->vol == b->vol)
				p->flags &= ~1;
		}
	}
	return b->stat;
}

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
		if ((char)flags & 0x40) {
			old = b;
use:
			if ((old->flags & 3) == 3 && (r->status = old->stat = SeqStep_FileBufferSetup(old)) != 0) {
				old->flags = 0;
				return old;
			}
			goto load;
		}
		if (b->vol == r->vol && sec == b->sec) {
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
		if ((p->flags & 1) && r->vol == p->vol && p->sec == sec)
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
	if (!((char)flags & 0x20)) {
		r->status = old->stat = r->dev->rsec(sec, old);
		if (old->stat != 0 && (r->vol->vflags & 2)) {
			r->status = old->stat = r->dev->rsec(sec, old);
			r->vol->vflags &= ~2;
		}
		i = 1;
		while (old->stat != 0 && ((char)flags & 4) && i++ < r->vol->geom->nfat) {
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
	unsigned long pos;
	long sec;
	struct buf *b;
	int fat16;
	unsigned int val;
	unsigned int off;
	struct vrec *v;

	fat16 = 0;
	if ((v = f->vrec)->mask == 0xfff)
		pos = n * 3 / 2;
	else {
		fat16 = 1;
		pos = (unsigned long)n * 2;
	}
	off = pos & 0x1ff;
	sec = (pos >> 9) + v->fatstart;
	b = f->lastbuf = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 4);
	if (b == 0)
		return v->mask - 8;
	val = *(unsigned char *)((unsigned long)off + 0x1a + (unsigned long)b);
	if (off == 0x1ff) {
		b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 4);
		if (b == 0)
			return v->mask - 8;
		val += (unsigned int)b->data[0] << 8;
	} else
		val += (unsigned int)*(unsigned char *)((unsigned long)(off + 1) + 0x1a + (unsigned long)b) << 8;
	if (fat16)
		return val;
	if (n & 1)
		return val >> 4;
	return val & 0xfff;
}

/* Maps f's position to an absolute sector (*psec) and the sectors that follow it contiguously (*pcnt); alloc:
   clusters to add when the chain ends on a writable file.  0, 39 (bad cluster), 8 (end of a read-only chain) or
   Fat_AllocateClusters' error. */
int __cdecl Fat_MapFilePosToSector(struct fil *f, int alloc, unsigned long *psec, unsigned int *pcnt)
{
	struct vrec *v;
	unsigned char so;
	unsigned int cl;
	unsigned long t;
	unsigned int n;
	int r;

	v = f->vrec;
	if (f->start == 0) {
		*psec = f->pos / v->bps + v->rootstart;
		*pcnt = v->rootsecs - (*psec - v->rootstart);
		return 0;
	}
	cl = (unsigned int)(f->pos / v->clbytes);
	t = f->pos % v->clbytes;
	so = t / v->bps;
	if (cl == f->curidx) {
		if (f->curclus == 0 && (f->flags3 & 2)) {
			if ((r = Fat_AllocateClusters(f, 0, alloc)) == 0)
				goto join;
			return r;
		}
		if (f->cnt == 0)
			Fat_CountContiguousClusters(f);
		goto join;
	}
	if (cl < f->curidx) {
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
