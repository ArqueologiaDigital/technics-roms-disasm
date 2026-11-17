/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_6m238b.c (2026-11-16-100-p6-r19)
   sha256 c6b79f56c96982fe7ea0565391c0b4bf48e7d9f4115473111e0fcf1668d85aa8 (tar-sha256); compiled at -Xr */
struct buf;
typedef int __cdecl SECFN(long, struct buf *);
struct dops { char pad[16]; SECFN *rsec; SECFN *wsec; };
struct vol;
struct buf { struct vol *vol; long sec; long l8; unsigned char *dptr; unsigned int cnt; char p18[2]; int stat;
	unsigned char flags; unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct rq;
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
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
	k = f->pos / v->clbytes;
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
	k /= v->bps;
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
