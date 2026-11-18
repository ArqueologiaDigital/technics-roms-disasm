/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m274b.c (2026-11-18-33-p6-r37)
   sha256 0633359f812dd552036c56639ab1bd517224430b839cf32b6c4d363acb24149c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char HexCharToNibble(int c);
void ConvertStrings(unsigned char *src, unsigned char *dst)
{
	for (;;) {
		if (*src == '~') {
			if (*++src == 0)
				break;
			*dst = HexCharToNibble(*src) << 4;
			if (*++src == 0)
				break;
			*dst += HexCharToNibble(*src);
		} else if (*src == 0) {
			*dst = *src;
			return;
		} else if (*src < 0x20)
			*dst = ' ';
		else
			*dst = *src;
		src++;
		dst++;
	}
	*dst = 0;
}
