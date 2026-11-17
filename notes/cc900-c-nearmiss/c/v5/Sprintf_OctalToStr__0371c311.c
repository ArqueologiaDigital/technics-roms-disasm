/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sprintf_core.c (2026-11-16-55-p6-r10)
   sha256 0371c311e1ba89b6d87f29506d83c141935448801ea655a25df72edd7954bccc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
char *__cdecl Sprintf_OctalToStr(char *p, unsigned long v)
{
	char *q;

	do {
		q = p++;
		*q = (char)((v & 7) + 0x30);
		v >>= 3;
	} while (v != 0);
	*p = 0;
	return p;
}
