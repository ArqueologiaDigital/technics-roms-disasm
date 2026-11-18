/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m238a.c (2026-11-18-28-p6-r36)
   sha256 f24805d5dee7a93dd223604a38b533be554f9952e02ca78dd9cdc211956c4a76 (tar-sha256); compiled at -O3 -Xr */
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

	if ((rc = Fat_MapFilePosToSector(f, 1, &sec, &off)) != 0)
		return rc;
	if ((f->buf = SeqStep_FileIoCheck(f, sec, f->buf, flags | 8)) == 0)
		return 10;
	return f->buf->stat;
}
