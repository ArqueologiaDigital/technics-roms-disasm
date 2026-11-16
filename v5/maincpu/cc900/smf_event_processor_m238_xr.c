/* Functions of sequencer/smf_event_processor.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
