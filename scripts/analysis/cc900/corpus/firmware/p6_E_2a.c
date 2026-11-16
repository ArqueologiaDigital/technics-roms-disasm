/* Phase 6, lane_p6 helper E, round 2, form a: refinements of round 1's near misses in v10
   sequencer/smf_event_processor.s (built -Xr) and audio/sprintf_core.s (built -O3 -XS -Xr), under their firmware
   names.  Forms a / b / c (p6_E_2a.c, p6_E_2b.c, p6_E_2c.c) have the same names:
   - byte-store spellings: a `% 256` and `>> 8`, b `% 256` and `/ 256`, c `(unsigned char)` casts;
   - FileIO_MatchWildcard: a block-scoped locals, b block scopes plus a dead `int n = 0`, c one scope;
   - Sprintf_FormatFFixed's rounding step: a `dig[--i]++` in a comma, b a for loop, c `dig[--i] += 1`. */

typedef void __cdecl PUTFN(int);

extern void *__cdecl Memset(void *, int, int);
extern void *__cdecl Mem_Copy(void *, void *, int);
extern unsigned char CType_ClassTable[];
extern int ram_3c220;
extern int ram_3c222;

#define E_ISLOWER(c) (CType_ClassTable[(unsigned char)(c)] & 2)
#define E_TOUPPER(c) (E_ISLOWER(c) ? (c) - 0x20 : (c))

#define LO16(x) ((x) % 256)
#define HI16(x) ((x) >> 8)
#define B32(x, n) (((x) >> (n)) % 256)
#define LO32(x) ((x) % 256)

/* sequencer/smf_event_processor.s */

int FileIO_MatchWildcard(char *name, char *pat)
{
	char buf[12];
	int r;

	if (*pat == 0)
		return 0;
	Memset(buf, '?', 11);
	buf[11] = 0;
	{
		char *p;

		p = buf;
		while (*pat != 0) {
			if (*pat == '.') {
				p = buf + 8;
				pat++;
			} else
				*p++ = *pat++;
		}
	}
	{
		int i;

		for (i = 0; i < 8; i++) {
			if (buf[i] == '*')
				for (; i < 8; i++)
					buf[i] = '?';
		}
		for (i = 8; i < 11; i++) {
			if (buf[i] == '*')
				for (; i < 11; i++)
					buf[i] = '?';
		}
	}
	{
		char *s;
		char *p;

		r = 1;
		s = name;
		p = buf;
		while (*s != 0) {
			if (*p != '?' && *s != *p) {
				r = 0;
				break;
			}
			s++;
			p++;
		}
	}
	return r;
}

void __cdecl SeqStep_FileSectorDone(unsigned int v, unsigned char **pp)
{
	*(*pp)++ = LO16(v);
	*(*pp)++ = HI16(v);
}

void __cdecl SeqStep_FileSectorReturn(unsigned char *e, unsigned char *dst)
{
	unsigned char *p;

	p = dst;
	Mem_Copy(dst, e, 11);
	p[11] = e[12];
	p += 22;
	*p++ = LO16(*(unsigned int *)(e + 13));
	*p++ = HI16(*(unsigned int *)(e + 13));
	*p++ = LO16(*(unsigned int *)(e + 15));
	*p++ = HI16(*(unsigned int *)(e + 15));
	*p++ = LO16(*(unsigned int *)(e + 17));
	*p++ = HI16(*(unsigned int *)(e + 17));
	*p++ = LO32(*(unsigned long *)(e + 19));
	*p++ = B32(*(unsigned long *)(e + 19), 8);
	*p++ = B32(*(unsigned long *)(e + 19), 16);
	*p = *(unsigned long *)(e + 19) >> 24;
}

/* audio/sprintf_core.s: %f / %F (and %g's fixed form).  dig = the decimal digits, ex = the decimal exponent. */
void __cdecl Sprintf_FormatFFixed(char spec, PUTFN *put, int flags, int width, int prec, char *dig, int ex,
	int neg)
{
	int nint;
	int maxd;
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
		while (dig[--i]++, i > 0 && dig[i] > '9')
			dig[i] = '0';
	if (E_TOUPPER(spec) == 'G') {
		i = prec - 1;
		prec += -ex;
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
