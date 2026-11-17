/* Phase 6, lane_p6 helper E, round 14, module 311 (notes/cc900-phase6-2026-11-16/modules_v10.tsv): v10
   audio/sprintf_core.s, written for -O3 -XS -Xr like its matched siblings Sprintf_FormatFFixed and
   Sprintf_FormatEScientific, under the firmware names.  FORM C of p6_E_14m311.c (form a): the arrays declared
   without sizes, as in round 13.  ROUND 14 (from round 13 form b, whose O3XSXr output already splits XIZ as the ROM does: e in IZ, the index in
   QIZ; first difference +39 once its `or (xde+qiz),0x30` is assembled, which the checker cannot do yet):
   - the 16-bit digit arrays: the ROM indexes them with a 16-bit register (`add bc,bc` / `(xwa+bc)`), V4.23 built
     32-bit pointers (`exts` / `ld xbc,sym` / `add`).  Here the arrays are declared with their sizes (32 words, 32
     chars), in case V4.23 then knows the offset fits 16 bits (form c: unsized, as round 13);
   - the sign: an if / else of two stores (the ROM sets WA in each branch, then stores once: a merged tail);
   - the exponent: the ROM extends `loc[0] & 0x7f` to a word before an arithmetic shift (`sla`), and extends the low
     nibble before `sra`; V4.23 shifted bytes.  Now through int variables, hi and lo, assigned before shifting;
   - form b: the long-double unpack into its own array ram_3c240 (form a: `ram_3c244[i - 2]`).
   Round 13's description: */
/* Sprintf_FormatGGeneral is misnamed: it is printf's float-to-decimal-digits converter.  val points at the IEEE
   double (8 bytes, little-endian; 10 for long double when flags bit 7), out receives the decimal digits as ASCII
   (maxd + 1 of them: 15, or 18 for long double), *pneg the sign and *pexp the decimal exponent.  It copies the bytes
   big-endian into loc, takes the binary exponent e (bias 0x400 from the 11-bit field, or 0x4000 from the 15-bit one),
   estimates the decimal exponent (Sprintf_DecimalExponent), unpacks the mantissa into the 16-bit digit array at
   0x3c244 (with the hidden bit, 0x10, for a normal double), scales it by tens (Divide / MultiplyDigitsByTen with the
   leading / trailing zero counts) until e is used up, shifts it (Sprintf_ShiftDigitArray), normalises each word to
   a decimal digit (Sprintf_NormalizeDigits), then writes the digits, rounds the last one and carries.
   Written from the hand source; the locals follow the slot rule seen in run 2026-11-17-2 (scalars bottom up in
   declaration order, the array on top): dexp +4, maxd +6, nb +8, loc +10; the ROM keeps e in IZ, the index in
   QIZ, the "nonzero byte seen" flag in IX, the output index in DE and out in XHL (V4.23's choices).
   The exponent's three values (low part, shift, bias) are variables: the ROM shifts by a register (`slaa`).
   The two scaling branches each end with their own Sprintf_ShiftDigitArray call (the ROM computes the arguments in
   both and shares only the call). */
/* cc900-module: Sprintf_CountLeadingZeros Sprintf_CountTrailingZeros Sprintf_DecimalExponent Sprintf_DivideDigitsByTen Sprintf_MultiplyDigitsByTen Sprintf_NormalizeDigits Sprintf_ShiftDigitArray */

extern void *__cdecl Memset(void *, int, int);
extern int __cdecl Sprintf_DecimalExponent(int e);
extern int __cdecl Sprintf_CountLeadingZeros(unsigned int *a, int n);
extern int __cdecl Sprintf_CountTrailingZeros(unsigned int *a, int n);
extern void __cdecl Sprintf_DivideDigitsByTen(unsigned int *a);
extern void __cdecl Sprintf_MultiplyDigitsByTen(unsigned int *a);
extern void __cdecl Sprintf_ShiftDigitArray(unsigned int *a, int sh, int n);
extern void __cdecl Sprintf_NormalizeDigits(unsigned int v, int i);

extern char ram_3c224[];
extern unsigned int ram_3c244[];
extern unsigned int ram_3c284[];

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
	for (i = 0; i < 32; i++) {
		ram_3c244[i] = 0;
		ram_3c284[i] = 0;
	}
	if (flags & 0x80) {
		maxd = 18;
		nb = 10;
	}
	for (i = 0; i < nb; i++)
		loc[i] = val[(unsigned int)(nb - 1 - i)];
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
			ram_3c244[i - 2] = loc[i] & 0xff;
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
