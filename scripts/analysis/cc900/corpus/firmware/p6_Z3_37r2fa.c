/* Probe round 37r2 (r1's +18: the file size's offset and the first compare's operand order), lane_z3 (feedback plan step Z3, the djnz pool): Fat_ReadFile of sequencer/smf_event_processor.s
   (module 238, the -Xr / __cdecl FAT code of smf_event_processor_m238_xr*.c).  fread-like: read up to n bytes of
   file f into buf from the current position; partial sectors through the sector cache (Mem_Copy, or byte by byte
   in text mode, flags3 bit 2, dropping CR and stopping after the end-of-line byte when `line` is set), whole
   sectors straight into buf (Fat_TransferSectorsDirect).  Status bit 15 marks a short read. */
/* cc900-module: Fat_GetSectorAtFilePos Fat_TransferSectorsDirect */

struct vrz { char p0[4]; unsigned long mask; char p8[30]; unsigned int bps; };
struct bufz { char p0[22]; unsigned char flags; char p23[3]; unsigned char data[512]; };
struct filz { char p0[2]; unsigned char eol; unsigned char flags3; char p4[2]; int status; char p8[14];
	unsigned long pos; char p26[4]; struct vrz *vrec; struct bufz *cache; char p38[33]; unsigned char size[4]; };
#define FSIZE(f) (*(unsigned long *)(f)->size)	/* +71: V4.23 aligns a long member to an even offset (r1: +72) */
extern int FILE_ERROR;
extern void *__cdecl Mem_Copy(void *, void *, int);
extern int __cdecl Fat_GetSectorAtFilePos(struct filz *f, int mode);
extern unsigned int __cdecl Fat_TransferSectorsDirect(struct filz *f, unsigned char *p, int count, int isread);

unsigned int __cdecl Fat_ReadFile(struct filz *f, unsigned char *buf, unsigned int n, int line)
{
	unsigned int total;
	unsigned int want;
	register unsigned int k;
	unsigned int off;
	unsigned int avail;
	unsigned char *src;
	int r;
	unsigned char c;

	total = 0;
	want = n;
	if (f->pos == FSIZE(f)) {
		f->status |= 0x8000;
		return 0;
	}
	n = n < FSIZE(f) - f->pos ? n : FSIZE(f) - f->pos;
	while (n != 0) {
		if ((f->vrec->mask & f->pos) != 0 || f->status == 35 || (f->flags3 & 4) != 0 || line != 0
		    || n < f->vrec->bps) {
			if (f->cache == 0 || (f->cache->flags & 1) == 0) {
				if ((r = Fat_GetSectorAtFilePos(f, 64)) != 0) {
					FILE_ERROR = (char)r;
					return total;
				}
			}
			off = f->vrec->mask & f->pos;
			avail = f->vrec->bps - off;
			src = &f->cache->data[off];
			if ((f->flags3 & 4) != 0 || line != 0)
				goto text;
			k = n < avail ? n : avail;
			Mem_Copy(buf, src, k);
			n -= k;
			buf += k;
			total += k;
			f->pos += k;
			if (n == 0)
				goto next;
		}
		k = Fat_TransferSectorsDirect(f, buf, n & ~f->vrec->mask, 1);
		if (f->status != 0)
			return total;
		n -= k;
		buf += k;
		total += k;
		f->pos += k;
		goto next;
text:
		for (k = n < avail ? n : avail; k != 0; k--) {
			if ((f->flags3 & 4) != 0 && *src == 13)
				src++;
			else {
				n--;
				total++;
				c = *src++;
				*buf++ = c;
				if (f->eol == c && line != 0) {
					n = 0;
					k = 1;
				}
			}
			f->pos += 1;
		}
next:
		if ((f->vrec->mask & f->pos) == 0) {
			f->cache->flags &= ~8;
			f->cache = 0;
		}
	}
	if (total < want)
		f->status |= 0x8000;
	return total;
}
