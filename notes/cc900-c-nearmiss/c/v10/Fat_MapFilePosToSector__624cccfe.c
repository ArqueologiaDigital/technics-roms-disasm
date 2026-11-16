/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_9m238c.c (2026-11-16-118-p6-r23)
   sha256 624cccfe2874951b69ee686bebe6b0309ac8627b23682e7ce96c7f117c50400d (tar-sha256); compiled at -Xr */
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
#define FIL_FIRSTCLUS(f) (*(unsigned int *)((char *)&(f)->curclus + 27))
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n);
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f);
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
