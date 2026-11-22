/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_24r1m128b.c (2026-11-22-1-p6-r69)
   sha256 833bebbd8bbc33acbb4f6da3b0d62c85bc1cbf3be8f63616b65b98771909dcc8 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
struct segrec { unsigned char pad[2]; unsigned int addr; unsigned char mask; unsigned char shift;
	unsigned char tail[9]; };
#define SEG_STYLE(s)	((s)->tail[0])
#define SEG_TEXT(s)	(*(unsigned char **)((s)->tail + 1))
#define SEG_LEN(s)	(*(unsigned int *)((s)->tail + 5))
#define SEG_POS(s)	(*(unsigned int *)((s)->tail + 7))
extern unsigned char Scoop_CharGlyphMap[];
extern long TextStyle_FontTable[];
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
void Scoop_CurveUpdate_SegmentEnd(struct segrec *s)
{
	long font;
	unsigned char v;
	struct rect clip;
	struct pt pt;
	char buf[256];
	unsigned char *p;
	unsigned char mask;
	unsigned char shift;
	unsigned int pos;
	unsigned int n;
	unsigned int i;

	p = (unsigned char *)s->addr;
	mask = s->mask;
	shift = s->shift;
	v = *p & mask;
	v >>= shift;
	pos = SEG_POS(s);
	n = SEG_LEN(s);
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	for (i = 0; i < n; i++) {
		p = SEG_TEXT(s);
		buf[i] = Scoop_CharGlyphMap[p[(unsigned long)(v * n) + i]];
	}
	buf[i] = 0;
	font = TextStyle_FontTable[SEG_STYLE(s) & 0x3f];
	pt.y -= 2;
	clip.x0 = pt.x;
	clip.x1 = pt.x + CalcTotalWidth(buf, font);
	clip.y0 = pt.y;
	clip.y1 = pt.y + GetCharHeight(font);
	DrawString(&clip, &pt, buf, font, 0xff, 0xf5);
}
