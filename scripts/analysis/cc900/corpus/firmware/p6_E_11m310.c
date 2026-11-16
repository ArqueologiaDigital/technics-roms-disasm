/* Phase 6, lane_p6 helper E, round 11, module 310 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   audio/sprintf_core.s, under the firmware names.  Form a; p6_E_11m310b.c and p6_E_11m310c.c have the same name.
   Sprintf_FormatEScientific: see p6_E_9m310.c for the routine.
   What runs 118 and 123 showed (round 9 form a, compared instruction by instruction):
   - at O3Xr V4.23 splits XIZ exactly as the ROM does (i in QIZ, neg and then the exponent's length in IZ), but the
     checker cannot assemble the ROM's own `inc 1,(xwa+qiz)` / `cp (xwa+qiz),imm` / `ld (xwa+qiz),imm` (llvm-mc has
     no such operand; the hand source writes the raw-byte pseudos inc_srib / cpib_sri / stib_ind), so that set was
     not counted.  Translated with those pseudos, O3Xr first differs at +98 and only in two kinds of spot:
     (1) the carry store, which the ROM writes `dig[i] = '0'; i--;` (fixed here, all forms);
     (2) six loops, which the ROM enters with a jump to the test at the bottom, where O3Xr copies the test to
     the entry: the left and zero padding, the trailing zeros, the exponent's lead zeros and digits, the right
     padding.
   - at O3XSXr (where FFixed matched) the loops come out as in the ROM, but V4.23 gives IZ to i and QIZ to the
     length; reusing neg for the length (round 10) only took neg out of its register.
   Form a aims at O3Xr: the six loops written as a jump into a do-while, so that the test is only at the bottom.
   Forms b and c aim at O3XSXr's register choice (see there).  Needs the checker to know the three (xRR+qiz)
   spellings (or their pseudos) before any form can match. */
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
	int len;

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
	if (!(flags & 2) && ram_3c220 == ' ') {
		goto padl;
		do {
			put(' ');
			ram_3c222++;
padl:			;
		} while (--width > 0);
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
	if (!(flags & 2) && ram_3c220 == '0') {
		goto padz;
		do {
			put('0');
			ram_3c222++;
padz:			;
		} while (--width > 0);
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
	goto trail;
	do {
		put('0');
		ram_3c222++;
trail:		;
	} while (prec-- > 0);
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
	goto lead;
	do {
		put('0');
		ram_3c222++;
lead:		;
	} while (i++ < 3);
	goto edig;
	do {
		put(dig[--len]);
		ram_3c222++;
edig:		;
	} while (len != 0);
	if (flags & 2) {
		goto padr;
		do {
			put(' ');
			ram_3c222++;
padr:			;
		} while (--width > 0);
	}
}
