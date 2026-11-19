/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_6b.c (2026-11-19-21-p6-r44)
   sha256 ceb7dccb744283a39de0525f353002b2735175b8455b660a51c656edf75e90d4 (tar-sha256); compiled at -O3 -Xr */
extern void *__cdecl Memset(void *, int, int);
extern int __cdecl Sprintf_DecimalExponent(int e);
extern int __cdecl Sprintf_CountLeadingZeros(unsigned int *a, int n);
extern int __cdecl Sprintf_CountTrailingZeros(unsigned int *a, int n);
extern void __cdecl Sprintf_DivideDigitsByTen(unsigned int *a);
extern void __cdecl Sprintf_MultiplyDigitsByTen(unsigned int *a);
extern void __cdecl Sprintf_ShiftDigitArray(unsigned int *a, int sh, int n);
extern void __cdecl Sprintf_NormalizeDigits(unsigned int v, int i);
extern char ram_3c224[32];
extern unsigned int ram_3c240[34];
extern unsigned int ram_3c244[32];
extern unsigned int ram_3c284[32];
void __cdecl Sprintf_FormatGGeneral(unsigned char *val, unsigned char *out, int flags, int *pexp, int *pneg)
{
	unsigned char loc[10];
	int dexp;
	int maxd;
	int nb;
	int e;
	int i;
	int found;
	int k;
	int lo;
	int sh;
	int bias;
	int hi;

	e = 0;
	maxd = 15;
	nb = 8;
	Memset(ram_3c224, 0, 32);
	for (i = 0; i < 32; i++)
		ram_3c284[i] = ram_3c244[i] = 0;
	if (flags & 0x80) {
		maxd = 18;
		nb = 10;
	}
	for (i = 0; i < nb; i++)
		*(loc + i) = *(val + (unsigned int)(nb - 1 - i));
	if (loc[0] & 0x80)
		*pneg = 1;
	else
		*pneg = 0;
	if ((flags & 0x80) && (loc[0] != 0 || loc[1] != 0)) {
		lo = loc[1];
		sh = 8;
		bias = 0x4000;
	} else if (loc[0] != 0 || loc[1] != 0) {
		lo = loc[1] & 0xf0;
		lo >>= 4;
		sh = 4;
		bias = 0x400;
	} else
		goto noexp;
	hi = loc[0] & 0x7f;
	e = (hi << sh) + lo - bias;
noexp:
	dexp = Sprintf_DecimalExponent(e);
	if (e < 0)
		dexp--;
	if (flags & 0x80) {
		for (i = 2; i < 10; i++)
			ram_3c240[i] = loc[i] & 0xff;
	} else {
		found = 0;
		for (i = 0; i < 8; i++)
			if (loc[i] != 0) {
				found = 1;
				break;
			}
		loc[1] &= 0xf;
		for (i = 1; i < 8; i++)
			ram_3c244[i - 1] = loc[i] & 0xff;
		if (found)
			ram_3c244[0] |= 0x10;
	}
	Sprintf_CountLeadingZeros(ram_3c244, nb);
	i = 0;
	if (e > 0) {
		for (; i < dexp; i++) {
			Sprintf_DivideDigitsByTen(ram_3c244);
			e -= Sprintf_CountLeadingZeros(ram_3c244, nb);
		}
		Sprintf_ShiftDigitArray(ram_3c244, 6 - e, maxd);
	} else {
		for (; i < -dexp; i++) {
			Sprintf_MultiplyDigitsByTen(ram_3c244);
			e += Sprintf_CountTrailingZeros(ram_3c244, nb);
		}
		Sprintf_ShiftDigitArray(ram_3c244, 6 - e, maxd);
	}
	for (i = 1; i < 9; i++)
		Sprintf_NormalizeDigits(ram_3c244[i], i);
	k = 0;
	if (ram_3c244[0] > 9) {
		k = 1;
		out[0] = ram_3c244[0] / 10;
		dexp++;
	}
	out[k++] = ram_3c244[0] % 10;
	dexp++;
	for (i = 1; i < maxd + 2; i++)
		out[k++] = ram_3c224[i];
	if (out[maxd + 1] >= 5)
		out[maxd]++;
	out[maxd + 1] = 0;
	for (i = maxd; i != 0 && out[i] > 9; i--) {
		out[i - 1]++;
		out[i] = 0;
	}
	for (i = 0; i < maxd + 1; i++)
		out[i] |= 0x30;
	*pexp = dexp;
}
