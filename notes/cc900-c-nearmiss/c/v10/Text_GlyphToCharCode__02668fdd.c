/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5b.c (2026-11-16-45-p6-r9)
   sha256 02668fddc4a7ae9f0dcae741aab0cb2afb9cebcd20d58654e0aa4bfa1965ed0a (tar-sha256); compiled at -O3 -Xr */
extern unsigned char Text_CharGlyphMap[];
void Text_GlyphToCharCode(unsigned char *in, unsigned char *out)
{
	int i;

	if (*in == 32 || *in == 0) {
		*out = *in;
		return;
	}
	for (i = 0; i < 256; i++)
		if (*in == Text_CharGlyphMap[i]) {
			*out = i;
			break;
		}
	if (i == 256) *out = 32;
}
