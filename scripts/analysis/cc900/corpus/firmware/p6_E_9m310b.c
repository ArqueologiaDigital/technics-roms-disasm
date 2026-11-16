/* Phase 6, lane_p6 helper E, round 9, module 310 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   audio/sprintf_core.s, built -O3 -XS -Xr like its sibling Sprintf_FormatFFixed (round 2 form b, now
   v10/maincpu/cc900/sprintf_core_m310_xs.c), under the firmware names.  FORM B of p6_E_9m310.c (form a, whose
   comment below holds; the differences are its last sentence).
   Sprintf_FormatEScientific: %e / %E (and %g's exponent form), with FFixed's parameters (dig = the decimal digits,
   ex = the decimal exponent).  Written from the hand source, in FFixed's idioms:
   - one stack local (maxd, 15 or 18 digits); the ROM keeps the digit index in QIZ and the exponent's length in IZ,
     and neg in IZ before that (V4.23's choice; nothing in the C asks for it);
   - rounding: `dig[i--] > '4'` in the test (the ROM reads the digit at the old index, from DE), then FFixed's
     for loop with the carry store `dig[i--] = '0'` as the body and the increment as both init and step;
   - padding loops `--width > 0` (the ROM decrements before it compares), the precision loops `prec-- > 0`;
   - a carry out of the lead digit moves the exponent towards zero: ex++ when negative, else ex--;
   - the exponent is written by Sprintf_IntToStr (same module: calr) into dig and measured by Strlen, one stack
     adjustment for both calls; the letter is spec - 2 for %g / %G.
   Form b: the letter as `(char)(spec - 2)`, the exponent sign through one `put(ex < 0 ? '-' : '+')`, and len
   declared before i. */
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
	int len;
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
	len = Strlen(dig);
	put(E_TOUPPER(spec) == 'G' ? (char)(spec - 2) : spec);
	ram_3c222++;
	put(ex < 0 ? '-' : '+');
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
