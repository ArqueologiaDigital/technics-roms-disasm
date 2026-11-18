/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_4m274a.c (2026-11-18-33-p6-r37)
   sha256 c69fdbc5fb1baa618817b1bf8556f56ad97690ebbffe1f88161ae68c310246d5 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char HexCharToNibble(int c);
void ConvertStrings(unsigned char *src, unsigned char *dst)
{
	for (;;) {
		if (*src == '~') {
			src++;
			if (*src == 0)
				goto term;
			*dst = HexCharToNibble(*src) << 4;
			src++;
			if (*src == 0)
				goto term;
			*dst += HexCharToNibble(*src);
			goto next;
term:
			*dst = 0;
			return;
		}
		if (*src == 0) {
			*dst = *src;
			return;
		}
		if (*src < 0x20)
			*dst = ' ';
		else
			*dst = *src;
next:
		src++;
		dst += 1;
	}
}
