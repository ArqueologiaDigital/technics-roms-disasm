/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/smf_event_processor_m238_xr.c (2026-11-16-68-p6-r12)
   sha256 539993119811115e959121d092ea58724f7d7549687c76f8de48351f32bb3d3c (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct buf;
struct file;
typedef int __cdecl SECFN(long, struct buf *);
typedef int __cdecl FILEFN(struct file *);
struct ops { char pad[20]; SECFN *wsec; char pad2[4]; FILEFN *f28; FILEFN *f32; };
struct file { char pad[14]; struct ops *ops; };
struct geom { char pad[48]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[14]; struct ops *ops; char pad2[8]; struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct hnd { char pad[6]; int w6; };
extern struct hnd *ram_210b4[];
extern struct buf ram_2121a[];
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
