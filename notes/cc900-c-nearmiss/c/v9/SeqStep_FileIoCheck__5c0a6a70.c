/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/smf_event_processor_m238_xr_b.c (2026-11-16-111-p6-r22-staged)
   sha256 5c0a6a708c16ea011d35386b66a6559ea8543ec0751df7eda20447645da749e2 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct buf;
typedef int __cdecl SECFN(long, struct buf *);
struct ops { char pad[20]; SECFN *wsec; };
struct dops { char pad[16]; SECFN *rsec; };
struct geom { char pad[12]; long l12; char pad1[32]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[2]; unsigned char vflags; char p3; char pad1[10]; struct ops *ops; char pad2[8];
	struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct rq { unsigned char drv; char p1; char pad[2]; char p4; unsigned char unit; int status; char pad1[2];
	struct dops *dev; char pad2[4]; struct vol *vol; };
#define BITS(n, m) ((unsigned char)(n) & (m))
extern struct buf ram_2121a[];
extern unsigned char ram_3e3e0;
int __cdecl SeqStep_FileBufferSetup(struct buf *b);
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
