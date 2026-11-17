/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/graphics_text_vga_m274.c (2026-11-16-111-p6-r22-staged)
   sha256 e0047bcfdaba88f656f2559c5d11064bef03bc2d2cdfbac2d871415c9ceb9038 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int __cdecl Strlen(char *);
extern char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern void __cdecl Free(void *);
extern int CalcTotalWidth(char *, long);
int WordwrapStrings(char *s, long font, int width)
{
	int n;
	char *b2;
	int best;
	char *buf;
	char *p;

	n = 0;
	best = 0;
	p = s;
	buf = Malloc(Strlen(p) + 1);
	b2 = buf;
	if (*p != 0) do {
		while (*p != 0) {
			if (*p == 0x20) break;
			p++;
			n++;
		}
		while (*p != 0) {
			if (*p != 0x20) break;
			p++;
			n++;
		}
		Strcpy(b2, s);
		b2[n] = 0;
		if (CalcTotalWidth(b2, font) <= width) best = n;
	} while (*p != 0);
	Free(buf);
	return best;
}
