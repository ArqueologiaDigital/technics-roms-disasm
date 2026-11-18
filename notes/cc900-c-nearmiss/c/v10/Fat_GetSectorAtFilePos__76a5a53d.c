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
extern int __cdecl Fat_MapFilePosToSector(struct rq *, int, long *, int *);
extern struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
int __cdecl Fat_GetSectorAtFilePos(struct rq *f, int flags)
{
	long sec;
	int off;
	int rc;

	if ((rc = Fat_MapFilePosToSector(f, 1, &sec, &off)) == 0) {
		if ((f->buf = SeqStep_FileIoCheck(f, sec, f->buf, flags | 8)) == 0)
			rc = 10;
		else
			rc = f->buf->stat;
	}
	return rc;
}
