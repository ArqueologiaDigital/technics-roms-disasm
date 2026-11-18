/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m238b.c (2026-11-18-28-p6-r36)
   sha256 76a5a53d99388142def22d2448fb7988ce06881b027eaf25d42da0a997d4d893 (tar-sha256); compiled at -O3 -Xr */
struct buf;
typedef int __cdecl SECFN(long, struct buf *);
typedef void __cdecl STAMPFN(unsigned char *);
struct dops { char pad[16]; SECFN *rsec; char pad2[4]; STAMPFN *stamp; };
struct vol;
struct buf { struct vol *vol; long sec; long l8; char pad[6]; int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct rq { unsigned char drv; char p1; char p2; unsigned char fl3; unsigned char b4; unsigned char unit; int status;
	char pad8[2]; struct dops *dev; char pad14[4]; struct vol *vol; long pos; long dirsec; char pad30[4];
	struct buf *buf; char pad38[13]; unsigned char slot; unsigned char ent[12]; unsigned char attr;
	unsigned char x65[9]; };
extern struct buf ram_2121a[];
extern int __cdecl SeqStep_FileBufferSetup(struct buf *b);
int __cdecl SeqStep_FileBufferFinal(struct rq *r)
{
	int rc;
	int i;
	struct buf *p;
	int e;

	rc = 0;
	p = ram_2121a;
	for (i = 0; i < 10; i++, p++) {
		if ((p->flags & 3) == 3) {
			e = SeqStep_FileBufferSetup(p);
			if (e != 0)
				rc = e;
		}
		if (r->unit == p->idx && (p->flags & 4) == 0)
			p->flags &= 0x80;
	}
	return rc;
}
