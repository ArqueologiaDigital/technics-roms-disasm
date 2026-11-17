/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_17m232.c (2026-11-16-123-p6-r25)
   sha256 b6d8d7c2146514593eec82af6592d8630f8da28dc76c06cf50954ca1feca79eb (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2742;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned char __near ram_27cc;
void BmDrEdit_SetRowOffsetFromDelta(unsigned char a, unsigned char c)
{
	a -= c;
	if (ram_2742 & 1) {
		ram_27cc = 11 - a;
		return;
	}
	ram_27cc = a;
	if (NOTEEDIT_BASE_KEY != 0) return;
	ram_27cc = a + 3;
}
