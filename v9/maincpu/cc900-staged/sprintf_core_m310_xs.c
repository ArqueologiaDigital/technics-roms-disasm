/* Functions of audio/sprintf_core.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -XS -Xr
*/
/* cc900-module: Sprintf_IntToStr */   /* scripts/analysis/cc900/module_calls.py v10 */

typedef void __cdecl PUTFN(int);
extern unsigned char CType_ClassTable[];
extern int ram_3c220;
extern int ram_3c222;
extern void __cdecl Sprintf_IntToStr(char *p, long v);
extern int __cdecl Strlen(char *);
#define E_ISLOWER(c) (CType_ClassTable[(unsigned char)(c)] & 2)
#define E_TOUPPER(c) (E_ISLOWER(c) ? (c) - 0x20 : (c))
extern void __cdecl Sprintf_FormatEScientific(char spec, PUTFN *put, int flags, int width, int prec, char *dig, int ex, int neg);

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
