/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/graphics_text_vga_m274.c (2026-11-16-68-p6-r12)
   sha256 0866c2b7aa868d3bcc2c8cf87e8cc42c575974fa788641d4bad8b27d424f2f1d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char Text_CharGlyphMap[];
void Text_GlyphToCharCode(unsigned char *in, unsigned char *out)
{
	int i;
	unsigned char e;

	e = *in;
	if (e == 32 || e == 0) {
		*out = *in;
		return;
	}
	for (i = 0; i < 256; i++)
		if (*in == Text_CharGlyphMap[i]) {
			*out = i;
			break;
		}
	if (i != 256) return;
	*out = 32;
}
