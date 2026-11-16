/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: CalcTotalWidth */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int __cdecl Strlen(char *);
extern char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern void __cdecl Free(void *);
extern int CalcTotalWidth(char *, long);
extern int WordwrapStrings(char *s, long font, int width);

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
