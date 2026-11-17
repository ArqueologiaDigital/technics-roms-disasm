/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/graphics_text_vga.c (2026-11-16-55-p6-r10)
   sha256 69cfebfca3d96eb693bdd47e9fa743b089974c6fec4fb0a8e24fcee70dbf23ef (tar-sha256); compiled at -O3 -Xr
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
