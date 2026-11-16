/* Phase 6, lane_p6 helper E, round 1, form b: routines of v10 sequencer/smf_event_processor.s (the FAT / stdio
   layer, cdecl) and audio/sprintf_core.s (printf's %f), each under its firmware name.  Form a (p6_E_1a.c) has the
   same names; b changes declarations, test order and spellings.  The routines with calr, register banks, Q registers or xor-zeroing were
   left out.  Plain extern: the ROM reaches the cell with a 24-bit operand. */

struct buf;
struct file;

typedef int __cdecl SECFN(long, struct buf *);
typedef int __cdecl FILEFN(struct file *);
typedef void __cdecl PUTFN(int);

struct ops { char pad[20]; SECFN *wsec; char pad2[4]; FILEFN *f28; FILEFN *f32; };
struct file { char pad[14]; struct ops *ops; };
struct geom { char pad[48]; unsigned int spf; char pad2[8]; unsigned char nfat; char pad3; };
struct vol { char pad[14]; struct ops *ops; char pad2[8]; struct geom *geom; };
struct buf { struct vol *vol; long sec; long l8; char pad[6]; int age; int stat; unsigned char flags;
	unsigned char idx; unsigned char drv; char pad2; unsigned char data[512]; };
struct hnd { char pad[6]; int w6; };

extern void *__cdecl Memset(void *, int, int);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern struct file *__cdecl FileOpen(char *, char *);
extern int __cdecl FileClose(struct file *);
extern int FILE_ERROR;
extern char FileOpenDefault_Str_w[];
extern char SeqStep_ByteBlockF245_Str_d[];
extern char SeqStep_ByteBlockF245_Str_wb[];
extern struct hnd *ram_210b4[];
extern struct buf ram_2121a[];
extern unsigned char CType_ClassTable[];
extern int ram_3c220;
extern int ram_3c222;

#define E_ISLOWER(c) (CType_ClassTable[(unsigned char)(c)] & 2)
#define E_TOUPPER(c) (E_ISLOWER(c) ? (c) - 0x20 : (c))

/* sequencer/smf_event_processor.s */

int FileIO_MatchWildcard(char *name, char *pat)
{
	char buf[12];
	char *p;
	int i;

	if (*pat == 0)
		return 0;
	Memset(buf, '?', 11);
	buf[11] = 0;
	p = buf;
	while (*pat != 0) {
		if (*pat == '.') {
			p = buf + 8;
			pat++;
		} else
			*p++ = *pat++;
	}
	for (i = 0; i < 8; i++) {
		if (buf[i] == '*')
			while (i < 8)
				buf[i++] = '?';
	}
	for (i = 8; i < 11; i++) {
		if (buf[i] == '*')
			while (i < 11)
				buf[i++] = '?';
	}
	p = buf;
	while (*name != 0) {
		if (*p != '?' && *p != *name)
			return 0;
		name++;
		p++;
	}
	return 1;
}

unsigned long __cdecl SeqStep_FileSectorProcess(unsigned char **pp)
{
	unsigned long v;
	unsigned long t;

	v = *(*pp)++;
	t = *(*pp)++;
	v += t << 8;
	t = *(*pp)++;
	v += t << 16;
	t = *(*pp)++;
	v += t << 24;
	return v;
}

void __cdecl SeqStep_FileSectorDone(unsigned int v, unsigned char **pp)
{
	*(*pp)++ = v & 0xff;
	*(*pp)++ = v >> 8;
}

void __cdecl SeqStep_FileSectorReturn(unsigned char *e, unsigned char *dst)
{
	unsigned char *p;

	p = dst;
	Mem_Copy(p, e, 11);
	p[11] = e[12];
	p += 22;
	*p++ = *(unsigned int *)(e + 13) & 0xff;
	*p++ = *(unsigned int *)(e + 13) >> 8;
	*p++ = *(unsigned int *)(e + 15) & 0xff;
	*p++ = *(unsigned int *)(e + 15) >> 8;
	*p++ = *(unsigned int *)(e + 17) & 0xff;
	*p++ = *(unsigned int *)(e + 17) >> 8;
	*p++ = *(unsigned long *)(e + 19) & 0xff;
	*p++ = (*(unsigned long *)(e + 19) >> 8) & 0xff;
	*p++ = (*(unsigned long *)(e + 19) >> 16) & 0xff;
	*p = *(unsigned long *)(e + 19) >> 24;
}

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

int __cdecl FileOpenDefault(char *name)
{
	struct file *fp;

	if ((fp = FileOpen(name, FileOpenDefault_Str_w)) == 0)
		return -1;
	return fp->ops->f32(fp);
}

int __cdecl SeqStep_ByteBlockF245(char *name)
{
	struct file *fp;
	int e;
	int r;

	e = FILE_ERROR;
	FILE_ERROR = 0;
	fp = FileOpen(name, SeqStep_ByteBlockF245_Str_d);
	if (fp != 0) {
		FileClose(fp);
		FILE_ERROR = 21;
		return -1;
	}
	if (FILE_ERROR != 5)
		return -1;
	FILE_ERROR = (char)e;
	fp = FileOpen(name, SeqStep_ByteBlockF245_Str_wb);
	if (fp == 0)
		return -1;
	r = fp->ops->f28(fp);
	FileClose(fp);
	return r;
}

/* audio/sprintf_core.s: %f / %F (and %g's fixed form).  dig = the decimal digits, ex = the decimal exponent. */

void __cdecl Sprintf_FormatFFixed(int spec, PUTFN *put, int flags, int width, int prec, char *dig, int ex,
	int neg)
{
	int maxd;
	int nint;
	int i;

	maxd = 15;
	if (ex < 1)
		nint = 0;
	else
		nint = ex;
	if (!(flags & 0x10))
		prec = 6;
	if (flags & 0x80)
		maxd = 18;
	if (E_TOUPPER(spec) == 'G')
		i = prec;
	else
		i = prec + ex;
	if (i < maxd + 1 && dig[i] > '4' && i >= 0)
		for (++dig[--i]; i > 0 && dig[i] > '9'; ++dig[--i])
			dig[i] = '0';
	if (E_TOUPPER(spec) == 'G') {
		i = prec - 1;
		prec -= ex;
	}
	if (E_TOUPPER(spec) == 'G' && !(flags & 8))
		while (dig[i] == '0') {
			i--;
			prec--;
		}
	if (!(flags & 0x10) || prec != 0)
		width--;
	if (neg != 0 || (flags & 5))
		width--;
	width -= nint + prec;
	if (*dig > '9')
		width--;
	if (width < 0)
		width = 0;
	if (!(flags & 2) && ram_3c220 == ' ')
		while (width-- > 0) {
			put(' ');
			ram_3c222++;
		}
	if (neg) {
		put('-');
		ram_3c222++;
	} else if (flags & 1) {
		put('+');
		ram_3c222++;
	} else if (flags & 4) {
		put(' ');
		ram_3c222++;
	}
	if (!(flags & 2) && ram_3c220 == '0')
		while (width-- > 0) {
			put('0');
			ram_3c222++;
		}
	if (*dig > '9' && ex >= 0) {
		put('1');
		*dig = '0';
		ram_3c222++;
	} else if (ex <= 0) {
		put('0');
		ram_3c222++;
	}
	for (i = 0; i < maxd + 1 && nint-- > 0; i++) {
		put(dig[i]);
		ram_3c222++;
	}
	while (nint-- > 0) {
		put('0');
		ram_3c222++;
	}
	if ((flags & 8) || prec != 0) {
		put('.');
		ram_3c222++;
	}
	while (ex < 0 && prec-- != 0) {
		if (ex + 1 == 0 && *dig > '9') {
			put('1');
			*dig = '0';
		} else
			put('0');
		ram_3c222++;
		ex++;
	}
	if (i < maxd + 1)
		while (i < maxd + 1 && prec-- > 0) {
			put(dig[i]);
			ram_3c222++;
			i++;
		}
	while (prec-- > 0) {
		put('0');
		ram_3c222++;
	}
	if (flags & 2)
		while (width-- > 0) {
			put(' ');
			ram_3c222++;
		}
}

/* 1 when the digit string holds only '0's. */
int __cdecl Sprintf_FFixed_DataTable(char *p)
{
	while (*p != 0)
		if (*p++ != '0')
			return 0;
	return 1;
}
