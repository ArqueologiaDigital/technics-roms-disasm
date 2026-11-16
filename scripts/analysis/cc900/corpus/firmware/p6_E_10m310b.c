/* Phase 6, lane_p6 helper E, round 10, module 310 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   audio/sprintf_core.s, built -O3 -XS -Xr like its sibling Sprintf_FormatFFixed
   (v10/maincpu/cc900/sprintf_core_m310_xs.c), under the firmware names.  FORM B of p6_E_10m310.c (form a, whose
   comment holds; the difference is its last sentence).
   Sprintf_FormatEScientific: see p6_E_9m310.c for the routine.  Run 118 (+68 at O3XSXr, both forms): V4.23 splits
   XIZ as the ROM does but gives the halves the other way round: IZ to the digit index i (and to neg, whose life
   ends before i's next one), QIZ to the exponent's length.  The ROM gives QIZ to i and IZ to neg and then to the
   length.  So here the length IS neg: the parameter is reused for Strlen's result, making it the longer-lived
   variable.  The exponent sign is round 9 form a's if / else (the ROM pushes '-' or '+' and shares the call);
   form b writes the letter `(char)(spec - 2)` (form a: `spec - 2`). */
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
		for (dig[i]++; i > 0 && dig[i] > '9'; dig[i]++)
			dig[i--] = '0';
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
	neg = Strlen(dig);
	put(E_TOUPPER(spec) == 'G' ? (char)(spec - 2) : spec);
	ram_3c222++;
	if (ex < 0)
		put('-');
	else
		put('+');
	ram_3c222++;
	i = neg;
	while (i++ < 3) {
		put('0');
		ram_3c222++;
	}
	while (neg != 0) {
		put(dig[--neg]);
		ram_3c222++;
	}
	if (flags & 2)
		while (--width > 0) {
			put(' ');
			ram_3c222++;
		}
}
