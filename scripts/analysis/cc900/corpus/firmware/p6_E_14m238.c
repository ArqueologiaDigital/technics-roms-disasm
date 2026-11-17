/* Phase 6, lane_p6 helper E, round 14, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   sequencer/smf_event_processor.s (built -Xr, cdecl), under the firmware names.  Form a; p6_E_14m238b.c has the
   same name.  Fat_CreateDirEntry(file, path): see p6_E_12m238.c for the routine.
   Run 2026-11-17-16: round 13's declaration order (n, v, p, psec, b at function level, name on top, prev in the
   subdirectory's block) gives every stack slot of the ROM, prev at +20 included (it shares the block region with
   the root block's psec / b space).  The only difference left, in both forms, is the root loop's counter: V4.23
   keeps it in BC, the ROM in HL, which the ROM also uses for Fat_AllocateClusters' result.  So here the counter
   and that result are one variable, i (one register candidate instead of two).  Form b also writes the bound
   test with the counter on the right (`(n > 16 ? 16 : n) > i`). */
/* cc900-module: FatPath_Next83Component Fat_AllocateClusters Fat_ReadEntry SeqStep_FileBufferSetup SeqStep_FileIoCheck SeqStep_FileSectorReturn */

struct buf;
struct vol;

typedef int __cdecl SECFN(long, struct buf *);
typedef void __cdecl STAMPFN(unsigned char *);

struct dops { char pad[16]; SECFN *rsec; SECFN *wsec; STAMPFN *stamp; };
struct buf { struct vol *vol; long sec; long l8; unsigned char *dptr; unsigned int cnt; char p18[2]; int stat;
	unsigned char flags; unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
/* the volume record a file points at (+30); a file's +18 points at a record whose +26 is the same kind */
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[2]; int rootent;
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
/* an open file; its directory entry (slot +51, name +52, attribute +64, time +65, first cluster +69, size +71) */
struct fil { char p0; char p1; char p2; unsigned char flags3; char p4; unsigned char unit; int status; char p8[2];
	struct dops *dev; char p14[4]; struct vol2 *vol; unsigned long pos; unsigned long start; struct vrec *vrec;
	struct buf *cache; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx;
	unsigned int w48; unsigned char b50; unsigned char slot; unsigned char ent[24]; };

extern void *__cdecl Mem_Copy(void *, void *, int);
struct buf *__cdecl SeqStep_FileIoCheck(struct fil *r, long sec, struct buf *b, int flags);
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n);
int __cdecl FatPath_Next83Component(char *dst, char **pp);
void __cdecl SeqStep_FileSectorReturn(unsigned char *e, unsigned char *dst);
int __cdecl SeqStep_FileBufferSetup(struct buf *b);

int __cdecl Fat_CreateDirEntry(struct fil *f, char *path)
{
	char name[12];
	int n;
	struct vrec *v;
	unsigned char *p;
	unsigned long *psec;
	struct buf *b;
	int i;

	v = f->vol->vrec;
	if (FatPath_Next83Component(name, &path) == 0) {
		psec = &f->start;
		*psec = v->rootstart;
		n = v->rootent;
		while (n >= 0) {
			b = SeqStep_FileIoCheck(f, *psec, 0, 24);
			if (b == 0)
				return f->status;
			if (b->stat != 0)
				return b->stat;
			p = b->data;
			for (i = 0; i < (n > 16 ? 16 : n); i++, p += 32)
				if (*p == 0xe5 || *p == 0) {
					f->slot = i;
found:
					f->curclus = 0;
					f->curidx = 0;
					f->b50 = 0;
					Mem_Copy(f->ent, name, 11);
					f->ent[12] = 0;
					*(unsigned int *)(f->ent + 17) = 0;
					*(unsigned long *)(f->ent + 19) = 0;
					f->cache = 0;
					f->dev->stamp(f->ent + 13);
					SeqStep_FileSectorReturn(f->ent, p);
					b->flags |= 2;
					b->flags &= ~0x18;
					return SeqStep_FileBufferSetup(b);
				}
			b->flags &= ~0x18;
			n -= 16;
			*psec += 1;
		}
		return 16;
	}
	{
		unsigned int prev;

		f->w48 = *(unsigned int *)(f->ent + 17);
		if (FatPath_Next83Component(name, &path) != 0)
			do
				;
			while (FatPath_Next83Component(name, &path) != 0);
		goto chk;
next:
		f->start = v->datastart + v->spc * (f->curclus - 2);
		for (n = 0; n < (int)v->spc; n++) {
			b = SeqStep_FileIoCheck(f, f->start, 0, 24);
			if (b == 0)
				return f->status;
			if (b->stat != 0)
				return b->stat;
			p = b->data;
			for (f->slot = 0; f->slot < 16; f->slot++, p += 32)
				if (*p == 0xe5 || *p == 0)
					goto found;
			b->flags &= ~0x18;
			f->start += 1;
		}
		prev = f->curclus;
		f->curclus = Fat_ReadEntry(f, f->curclus);
chk:
		if (f->curclus <= v->mask - 8)
			goto next;
		f->slot = 0;
		f->curclus = prev;
		if ((i = Fat_AllocateClusters(f, 1, 1)) == 0)
			goto next;
		return i;
	}
}
