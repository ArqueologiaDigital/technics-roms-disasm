/* Phase 6, lane_p6 helper D, round 13, module 274 (v10 display/graphics_text_vga.s), form a: WordwrapStrings.
   It copies the string into a scratch buffer word by word and returns the longest prefix (in characters) whose
   width, measured by CalcTotalWidth (same module, calr), still fits.  Strlen / Malloc / Strcpy / Free are the cdecl
   library.  Form b (p6_D_13m274b.c) declares the locals in the reverse order (their stack slots). */
/* cc900-module: CalcTotalWidth */   /* from scripts/analysis/cc900/module_calls.py v10 */

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
