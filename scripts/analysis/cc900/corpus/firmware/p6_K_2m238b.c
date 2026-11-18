/* Phase 6, lane_p6 helper K, round 2, module 238, form b of p6_K_2m238a.c: Fat_GetSectorAtFilePos with one return
   of a result local; SeqStep_FileBufferFinal with the write-back test nested; SeqStep_SectorCompareBlock with the
   compare's operands swapped (the ROM masks the argument first); Fat_WriteDirEntry addressing the slot as an array
   of 32-byte entries. */
/* cc900-module: Fat_MapFilePosToSector SeqStep_FileBufferSetup SeqStep_FileIoCheck SeqStep_FileSectorReturn */   /* scripts/analysis/cc900/module_calls.py v10 */

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
struct dirent32 { unsigned char b[32]; };

extern struct buf ram_2121a[];
extern int FILE_ERROR;
extern int __cdecl Fat_MapFilePosToSector(struct rq *, int, long *, int *);
extern struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
extern int __cdecl SeqStep_FileBufferSetup(struct buf *b);
extern void __cdecl SeqStep_FileSectorReturn(unsigned char *e, unsigned char *dst);
extern int __cdecl Fat_GetSectorAtFilePos(struct rq *f, int flags);
extern int __cdecl Fat_WriteDirEntry(struct rq *f);
extern int __cdecl SeqStep_FileBufferFinal(struct rq *r);
extern int __cdecl SeqStep_SectorCompareBlock(struct rq *f, int set, int mode);

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

int __cdecl Fat_WriteDirEntry(struct rq *f)
{
	struct buf *b;

	f->dev->stamp(f->x65);
	b = SeqStep_FileIoCheck(f, f->dirsec, 0, 26);
	if (b == 0)
		return 10;
	SeqStep_FileSectorReturn(f->ent, ((struct dirent32 *)b->data)[f->slot].b);
	b->flags &= ~0x18;
	return 0;
}

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

int __cdecl SeqStep_SectorCompareBlock(struct rq *f, int set, int mode)
{
	if (set != 0) {
		if ((mode & 0x18) != (f->attr & 0x18)) {
			FILE_ERROR = 13;
			return -1;
		}
		f->attr = mode;
		f->fl3 |= 0x80;
	}
	return f->attr;
}
