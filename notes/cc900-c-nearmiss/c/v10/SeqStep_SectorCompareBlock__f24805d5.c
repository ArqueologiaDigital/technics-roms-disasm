/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_2m238a.c (2026-11-18-28-p6-r36)
   sha256 f24805d5dee7a93dd223604a38b533be554f9952e02ca78dd9cdc211956c4a76 (tar-sha256); compiled at -Xr */
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
extern int FILE_ERROR;
int __cdecl SeqStep_SectorCompareBlock(struct rq *f, int set, int mode)
{
	if (set != 0) {
		if ((f->attr & 0x18) != (mode & 0x18)) {
			FILE_ERROR = 13;
			return -1;
		}
		f->attr = mode;
		f->fl3 |= 0x80;
	}
	return f->attr;
}
