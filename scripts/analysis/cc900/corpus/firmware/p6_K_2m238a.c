/* Phase 6, lane_p6 helper K, round 2, module 238 (sequencer/smf_event_processor.s, the FAT library), form a.
   All __cdecl (stack arguments, caller pops), like the module's matched SeqStep_FileBufferSetup / SeqStep_FileIoCheck
   (cc900/smf_event_processor_m238_xr*.c, -Xr); struct buf is theirs.  struct rq is the open-file / request block:
   drive +0, flags +3, device byte +4, unit +5, status +6, device ops +10, volume +18, position +22, directory sector
   +26, cache buffer +34, directory slot +51, the unpacked entry +52 (attribute +64), +65 time stamp.
   Fat_GetSectorAtFilePos(f, flags): position -> sector (Fat_MapFilePosToSector, its error returned as is), then the
   cache buffer with flags | 8; 10 when none, else the buffer's status.  Locals: the offset word sits below the
   sector long (both address-taken: declared sector first).
   Fat_WriteDirEntry(f): time-stamps the entry through the device's +24 hook, gets the directory sector (flags 26),
   packs the entry into its 32-byte slot and clears bits 3/4 of the buffer flags.
   SeqStep_FileBufferFinal(r): flushes every dirty buffer of the 10; keeps the last non-zero result; buffers of r's
   unit that are not locked (bit 2) keep only bit 7.
   SeqStep_FileSectorComplete(e, raw): unpacks a raw 32-byte directory entry into e (the twin of the matched
   SeqStep_FileSectorReturn).
   SeqStep_SectorCompareBlock(f, set, mode): optionally sets the attribute (error 13 when bits 3/4 differ), marks
   the file dirty (+3 bit 7), returns the attribute. */
/* cc900-module: Fat_MapFilePosToSector SeqStep_FileBufferSetup SeqStep_FileIoCheck SeqStep_FileSectorProcess SeqStep_FileSectorRead SeqStep_FileSectorReturn */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern int FILE_ERROR;
extern void *__cdecl Mem_Copy(void *, void *, int);
extern int __cdecl Fat_MapFilePosToSector(struct rq *, int, long *, int *);
extern struct buf *__cdecl SeqStep_FileIoCheck(struct rq *r, long sec, struct buf *b, int flags);
extern int __cdecl SeqStep_FileBufferSetup(struct buf *b);
extern void __cdecl SeqStep_FileSectorReturn(unsigned char *e, unsigned char *dst);
extern unsigned int __cdecl SeqStep_FileSectorRead(unsigned char **pp);
extern unsigned long __cdecl SeqStep_FileSectorProcess(unsigned char **pp);
extern int __cdecl Fat_GetSectorAtFilePos(struct rq *f, int flags);
extern int __cdecl Fat_WriteDirEntry(struct rq *f);
extern int __cdecl SeqStep_FileBufferFinal(struct rq *r);
extern void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw);
extern int __cdecl SeqStep_SectorCompareBlock(struct rq *f, int set, int mode);

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

int __cdecl Fat_WriteDirEntry(struct rq *f)
{
	struct buf *b;

	f->dev->stamp(f->x65);
	b = SeqStep_FileIoCheck(f, f->dirsec, 0, 26);
	if (b == 0)
		return 10;
	SeqStep_FileSectorReturn(f->ent, &b->data[f->slot * 32]);
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
		if ((p->flags & 3) == 3 && (e = SeqStep_FileBufferSetup(p)) != 0)
			rc = e;
		if (r->unit == p->idx && !(p->flags & 4))
			p->flags &= 0x80;
	}
	return rc;
}

void __cdecl SeqStep_FileSectorComplete(unsigned char *e, unsigned char *raw)
{
	unsigned char *p;

	p = raw + 22;
	Mem_Copy(e, raw, 11);
	e[11] = 0;
	e[12] = raw[11];
	*(unsigned int *)(e + 13) = SeqStep_FileSectorRead(&p);
	*(unsigned int *)(e + 15) = SeqStep_FileSectorRead(&p);
	*(unsigned int *)(e + 17) = SeqStep_FileSectorRead(&p);
	*(unsigned long *)(e + 19) = SeqStep_FileSectorProcess(&p);
}

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
