/* Phase 6, lane_p6 helper E, round 4, module 238 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): FAT cluster
   chain routines of v10 sequencer/smf_event_processor.s (built -Xr), under the firmware names.  Form a;
   p6_E_4m238b.c has the same names (b: FAT bytes addressed as integers, the other operand order in the 12-bit
   merges, `(char)` bit tests, the && loop test in Fat_CountContiguousClusters, `sec = s = ...` before the zeroing loop).
   SeqStep_FileSectorPopReturn is the writing twin of Fat_ReadEntry: it stores FAT entry n = val.
   Every byte store is wrapped in an (unsigned char) cast: that keeps V4.23's operation at the ROM's width. */
/* cc900-module: Fat_ReadEntry Fat_WriteDirEntry SeqStep_FileBufferFinal SeqStep_FileIoCheck SeqStep_FileSectorPopReturn */

struct buf { struct vol *vol; long sec; long l8; char pad[6]; unsigned int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct rq { unsigned char drv; char p1; char pad[2]; char p4; unsigned char unit; int status; char pad1[2];
	struct dops *dev; char pad2[4]; struct vol *vol; };
/* the volume record a file points at (+30); a file's +18 points at a record whose +26 is the same kind */
struct vrec { char pad[20]; unsigned long datastart; unsigned long fatstart; unsigned long rootstart;
	unsigned long spc; unsigned int mask; unsigned int bps; unsigned int clbytes; char pad1[4];
	unsigned int rootsecs; char pad2[6]; unsigned int maxcl; };
struct vol2 { char pad[26]; struct vrec *vrec; };
/* an open file */
struct fil { char p0[3]; unsigned char flags3; char p4[14]; struct vol2 *vol; unsigned long pos; unsigned long start;
	struct vrec *vrec; char p34[4]; struct buf *lastbuf; unsigned int curclus; unsigned int cnt; unsigned int curidx; };

#define FIL_FIRSTCLUS(f) (*(unsigned int *)((char *)(f) + 69))
#define FATB(b, i) ((b)->data[(unsigned long)(i)])
#define BIT0(n) ((unsigned char)(n) & 1)

extern void *__cdecl Memset(void *, int, int);
struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
unsigned int __cdecl Fat_ReadEntry(struct fil *f, unsigned int n);
int __cdecl Fat_WriteDirEntry(struct fil *f);
int __cdecl SeqStep_FileBufferFinal(struct fil *f);
void __cdecl SeqStep_FileSectorPopReturn(struct fil *f, unsigned int n, unsigned int val);

/* Stores val as FAT entry n of f's volume (FAT12 when the mask is 0xfff, else FAT16). */
void __cdecl SeqStep_FileSectorPopReturn(struct fil *f, unsigned int n, unsigned int val)
{
	unsigned int off;
	struct vrec *v;
	unsigned long pos;
	long sec;
	struct buf *b;

	v = f->vrec;
	if (v->mask == 0xfff) {
		pos = n * 3 / 2;
		off = pos & 0x1ff;
		sec = (pos >> 9) + v->fatstart;
		f->lastbuf = b = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 6);
		if (b == 0)
			return;
		if (BIT0(n)) {
			FATB(b, off) = (unsigned char)(((val & 0xf) << 4) | (FATB(b, off) & 0xf));
			if (off == 0x1ff) {
				b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 6);
				if (b == 0)
					return;
				b->data[0] = val >> 4;
			} else
				FATB(b, off + 1) = val >> 4;
		} else {
			FATB(b, off) = (unsigned char)(val & 0xff);
			if (off == 0x1ff) {
				b = SeqStep_FileIoCheck((struct rq *)f, sec + 1, 0, 6);
				if (b == 0)
					return;
				b->data[0] = (unsigned char)(((val >> 8) & 0xf) | (b->data[0] & 0xf0));
			} else
				FATB(b, off + 1) = (unsigned char)(((val >> 8) & 0xf) | (FATB(b, off + 1) & 0xf0));
		}
	} else {
		pos = (unsigned long)n * 2;
		off = pos & 0x1ff;
		sec = (pos >> 9) + v->fatstart;
		f->lastbuf = b = SeqStep_FileIoCheck((struct rq *)f, sec, f->lastbuf, 6);
		if (b == 0)
			return;
		FATB(b, off) = (unsigned char)(val & 0xff);
		FATB(b, off + 1) = val >> 8;
	}
}

/* Length of the contiguous run from the file's current cluster (+42), stored in +44 and returned. */
unsigned int __cdecl Fat_CountContiguousClusters(struct fil *f)
{
	unsigned int c;
	unsigned int last;
	unsigned int n;

	last = f->vrec->mask - 8;
	c = f->curclus;
	if (c == 0) {
		f->cnt = 0;
		return 0;
	}
	f->cnt = 1;
	while ((n = Fat_ReadEntry(f, c)) <= last) {
		if (++c != n)
			break;
		f->cnt++;
	}
	return f->cnt;
}

/* Finds n free clusters (searching up from the current one, then from 2) and links them to the file; zero: clear
   the last one's sectors.  0, 15 (disk full) or 10 / a buffer status on I/O failure. */
int __cdecl Fat_AllocateClusters(struct fil *f, int zero, int n)
{
	unsigned int maxcl;
	unsigned int last;
	unsigned int prev;
	unsigned int run;
	struct vrec *q;
	unsigned int cl;
	unsigned long s;
	unsigned long sec;
	struct buf *b;

	prev = 0;
	run = 0;
	q = f->vol->vrec;
	maxcl = f->vrec->maxcl;
	last = f->curclus;
	while (n-- != 0) {
		cl = last + 1 < 2 ? 2 : last + 1;
		for (; cl <= maxcl; cl++)
			if (Fat_ReadEntry(f, cl) == 0)
				goto found;
		for (cl = 2; cl < last; cl++)
			if (Fat_ReadEntry(f, cl) == 0)
				goto found;
		Fat_WriteDirEntry(f);
		SeqStep_FileBufferFinal(f);
		return 15;
found:
		SeqStep_FileSectorPopReturn(f, cl, f->vrec->mask);
		if (FIL_FIRSTCLUS(f) == 0)
			FIL_FIRSTCLUS(f) = cl;
		else {
			SeqStep_FileSectorPopReturn(f, last, cl);
			if (prev == 0)
				f->curidx++;
		}
		last = cl;
		if (++run == cl)
			f->cnt++;
		else
			run = 0;
		if (prev == 0) {
			run = prev = f->curclus = cl;
			f->cnt = 1;
		}
	}
	if (zero != 0) {
		s = q->datastart + q->spc * (cl - 2);
		for (sec = s; sec < s + q->spc; sec++) {
			if ((b = SeqStep_FileIoCheck((struct rq *)f, sec, 0, 0x22)) == 0)
				return 10;
			if (b->stat != 0)
				return b->stat;
			Memset(b->data, 0, 512);
		}
	}
	return 0;
}
