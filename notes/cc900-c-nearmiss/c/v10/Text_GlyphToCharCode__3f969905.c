/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_4b.c (2026-11-16-40-p6-r8)
   sha256 3f9699055ea8ee760c6182765bb0c18af9ae963c90014c6f6548598332507ab7 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char Text_CharGlyphMap[];
void Text_GlyphToCharCode(unsigned char *in, unsigned char *out)
{
	int i;

	if (*in == 32 || *in == 0) {
		*out = *in;
		return;
	}
	for (i = 0; i < 256; i++)
		if (Text_CharGlyphMap[i] == *in) {
			*out = i;
			break;
		}
	if (i == 256) *out = 32;
}
