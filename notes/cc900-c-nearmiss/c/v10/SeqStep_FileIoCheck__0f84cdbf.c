/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_E_2m238.c (2026-11-16-72-p6-r13)
   sha256 0f84cdbf784f548f14fd081c6a66c2b986a555cb105a387f3d50f98267cb1f08 (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper E, round 2, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): the FAT sector
   cache of v10 sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Fat_ReadEntry calls
   SeqStep_FileIoCheck, which calls SeqStep_FileBufferSetup, both with calr, so the three are in one file.
   SeqStep_FileBufferSetup is round 1's form b, which V4.23 matched (run 55, -Xr).
   cc900-module: SeqStep_FileBufferSetup SeqStep_FileIoCheck */

struct buf;

typedef int __cdecl SECFN(long, struct buf *);

struct ops { char pad[20]; SECFN *wsec; };
struct dops { char pad[16]; SECFN *rsec; };
struct geom { char pad[12]; long l12; char pad1[32]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[2]; unsigned char vflags; char pad1[11]; struct ops *ops; char pad2[8]; struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct hnd { char pad[6]; int w6; };
/* the request: the open file / directory search record */
struct rq { unsigned char drv; char pad[4]; unsigned char unit; int status; char pad1[2]; struct dops *dev;
	char pad2[4]; struct vol *vol; };
/* the volume record a file points at (+30) */
struct vrec { char pad[24]; long fatstart; char pad1[8]; unsigned int mask; };
struct fh { char pad[30]; struct vrec *vrec; char pad1[4]; struct buf *lastbuf; };

extern struct hnd *ram_210b4[];
extern struct buf ram_2121a[];
extern unsigned char ram_3e3e0;

int __cdecl SeqStep_FileBufferSetup(struct buf *b);
struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);

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
		if (flags & 0x40) {
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
		if ((b->age += 20) & 0x8000)
			ram_3e3e0 = 1;
		b->flags |= flags;
		b->idx = r->unit;
		return b;
	}
	if (old != 0)
		goto use;
	r->status = 10;
	return 0;
load:
	old->sec = sec;
	old->vol = r->vol;
	old->idx = r->unit;
	old->drv = r->drv;
	old->stat = 0;
	if (!(flags & 0x20)) {
		r->status = old->stat = r->dev->rsec(sec, old);
		if (old->stat != 0 && (r->vol->vflags & 2)) {
			r->status = old->stat = r->dev->rsec(sec, old);
			r->vol->vflags &= ~2;
		}
		i = 1;
		while (old->stat != 0 && (flags & 4) && i++ < r->vol->geom->nfat) {
			sec += r->vol->geom->spf;
			r->status = old->stat = r->dev->rsec(sec, old);
		}
	}
	old->l8 = r->vol->geom->l12;
	if (old->stat != 0) {
		old->flags = 0;
		r->status = old->stat;
		return 0;
	}
	old->flags = (flags & ~0x20) | 1;
	if ((old->age = 20) & 0x8000)
		ram_3e3e0 = 1;
	return old;
}

/* FAT entry n of file f's volume: FAT12 when the volume's mask is 0xfff, else FAT16. */
unsigned int __cdecl Fat_ReadEntry(struct fh *f, unsigned int n)
{
	struct vrec *v;
	unsigned int off;
	unsigned int val;
	int fat16;
	unsigned long pos;
	long sec;
	struct buf *b;

	fat16 = 0;
	v = f->vrec;
	if (v->mask == 0xfff)
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
	val = b->data[off];
	if (off == 0x1ff) {
		b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 4);
		if (b == 0)
			return v->mask - 8;
		val += (unsigned int)b->data[0] << 8;
	} else
		val += (unsigned int)b->data[off + 1] << 8;
	if (fat16)
		return val;
	if (n & 1)
		return val >> 4;
	return val & 0xfff;
}
