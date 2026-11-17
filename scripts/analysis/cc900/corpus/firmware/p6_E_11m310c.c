/* Phase 6, lane_p6 helper E, round 11, module 310: v10 audio/sprintf_core.s, under the firmware names.  FORM C of
   p6_E_11m310.c (form a, whose comment gives the evidence).  Aims at O3XSXr like form b, with plain while loops and
   the carry store fixed; here the length is declared first and initialised (`int len = 0;`), the lead-zero count is
   i again: does an earlier first appearance move the length to IZ and i to QIZ, as in the ROM? */
/* cc900-module: Sprintf_IntToStr */

typedef void __cdecl PUTFN(int);

extern unsigned char CType_ClassTable[];
extern int ram_3c220;
extern int ram_3c222;

extern void __cdecl Sprintf_IntToStr(char *p, long v);
extern int __cdecl Strlen(char *);

#define E_ISLOWER(c) (CType_ClassTable[(unsigned char)(c)] & 2)
#define E_TOUPPER(c) (E_ISLOWER(c) ? (c) - 0x20 : (c))

void __cdecl Sprintf_FormatEScientific(char spec, PUTFN *put, int flags, int width, int prec, char *dig, int ex,
	int neg)
{
	int len = 0;
	int maxd;
	int i;

	maxd = 15;
	if (!(flags & 0x10))
		prec = 6;
	if (E_TOUPPER(spec) == 'G' && prec != 0)
		prec--;
	i = prec + 1;
	if (flags & 0x80)
		maxd = 18;
	if (i < maxd + 1 && dig[i--] > '4')
		for (dig[i]++; i > 0 && dig[i] > '9'; dig[i]++) {
			dig[i] = '0';
			i--;
		}
	if (E_TOUPPER(spec) == 'G' && !(flags & 8)) {
		i = prec;
		while (i > 0 && dig[i] == '0') {
			i--;
			prec--;
		}
	}
	width -= 5;
	if (!(flags & 0x10) || prec != 0)
		width--;
	if (neg != 0 || (flags & 5))
		width--;
	width -= prec;
	if (width < 0)
		width = 0;
	if (!(flags & 2) && ram_3c220 == ' ')
		while (--width > 0) {
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
		while (--width > 0) {
			put('0');
			ram_3c222++;
		}
	if (*dig > '9') {
		put('1');
		*dig = '0';
		i = 0;
		ram_3c222++;
		if (ex < 0)
			ex++;
		else
			ex--;
	} else {
		put(*dig);
		ram_3c222++;
		i = 1;
	}
	if (prec != 0 || (flags & 8)) {
		put('.');
		ram_3c222++;
	}
	if (E_TOUPPER(spec) == 'G' && prec == 0 && ex == 1)
		return;
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
	ex--;
	Sprintf_IntToStr(dig, ex);
	len = Strlen(dig);
	put(E_TOUPPER(spec) == 'G' ? spec - 2 : spec);
	ram_3c222++;
	if (ex < 0)
		put('-');
	else
		put('+');
	ram_3c222++;
	i = len;
	while (i++ < 3) {
		put('0');
		ram_3c222++;
	}
	while (len != 0) {
		put(dig[--len]);
		ram_3c222++;
	}
	if (flags & 2)
		while (--width > 0) {
			put(' ');
			ram_3c222++;
		}
}
