/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct fs { unsigned int w, h; long x; };
extern unsigned char Text_CharGlyphMap[];

void GetFrameSPSize(unsigned int i, unsigned int *w, unsigned int *h)
{
	struct fs *f = (struct fs *)0x934000 + i;

	*w = f->w;
	*h = f->h;
}

unsigned char HexCharToNibble(unsigned char a)
{
	if (a >= 0x30 && a <= 0x39) return a - 0x30;
	if (a >= 0x61 && a <= 0x66) return a - 0x57;
	if (a >= 0x41 && a <= 0x46) return a - 0x37;
	return 0;
}

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

/* cc900-module: CalcTotalWidth */
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

/* cc900-module: HexCharToNibble */
extern unsigned char HexCharToNibble(int c);
extern void ConvertStrings(unsigned char *src, unsigned char *dst);

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

/* cc900-module: SetDialFocus */
struct glyph { long bits; int descent; int w; long rest; int pad; int pad2; };
extern int GetCharDescent(unsigned long c);
struct font { unsigned int w; unsigned int h; unsigned char pad[12]; };
extern unsigned int GetCharHeight(unsigned long id);

int GetCharDescent(unsigned long c)
{
  return ((struct glyph *)0x945c00L)[c].descent;
}
unsigned int GetCharHeight(unsigned long id)
{
  return ((struct font *)0x945c00L)[id].h;
}
