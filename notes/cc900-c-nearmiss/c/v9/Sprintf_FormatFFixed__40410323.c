/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sprintf_core_m310_xs.c (2026-11-16-92-p6-r18)
   sha256 404103239e9e7a1d80c9743b3c7eebbdd68ff05a58231488bcad210dc047667e (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -XS -Xr */
typedef void __cdecl PUTFN(int);
extern unsigned char CType_ClassTable[];
extern int ram_3c220;
extern int ram_3c222;
#define E_ISLOWER(c) (CType_ClassTable[(unsigned char)(c)] & 2)
#define E_TOUPPER(c) (E_ISLOWER(c) ? (c) - 0x20 : (c))
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
		for (dig[--i]++; i > 0 && dig[i] > '9'; dig[--i]++)
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
