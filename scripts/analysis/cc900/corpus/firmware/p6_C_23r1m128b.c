/* Form b: form a with the glyph row indexed by `(unsigned long)v * n + i` (the ROM multiplies v by n into XWA with
   `mul` and adds the 32-bit product to the extended i before adding the row pointer).
   lane_p6 helper C, round 23r1, form b (from form a): module 128 (display/scoop_display.s), the Scoop curve / envelope pair of pool
   roots23_A (helper A's 22r2 files hold the small handlers after them): Scoop_CurveUpdate_SegmentEnd and its twin
   Scoop_EnvelopeCalc_Data, which also lifts the clip box's bottom by the font's descent.
   The record: +2 a near address whose byte is masked (+4) and shifted (+5) into a row number, +6 a font style
   (low 6 bits index TextStyle_FontTable), +7 a far pointer to rows of glyph codes, +11 the row length, +13 a text cell
   (row = cell / 40, x = (cell % 40) * 8).  The row is translated through Scoop_CharGlyphMap and drawn with DrawString
   clipped to its own width / height, two pixels higher.
   The fields from +7 sit at odd offsets, so they are read through casts (V4.23 aligns struct members).
   Unoptimised shape (stores and reloads of the frame cells, div then muls): the -Xr set, like helper A's 22r2m128.
   cc900-options: -Xr
*/

struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
struct segrec { unsigned char pad[2]; unsigned int addr; unsigned char mask; unsigned char shift; unsigned char style;
	unsigned char rest[8]; };

#define SEG_TEXT(s)	(*(unsigned char **)((s)->rest))
#define SEG_LEN(s)	(*(unsigned int *)((s)->rest + 4))
#define SEG_POS(s)	(*(unsigned int *)((s)->rest + 6))

extern unsigned char Scoop_CharGlyphMap[];
extern long TextStyle_FontTable[];
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);

void Scoop_CurveUpdate_SegmentEnd(struct segrec *s)
{
	long font;
	unsigned char v;
	char buf[256];
	struct pt pt;
	struct rect clip;
	unsigned int pos;
	unsigned int n;
	unsigned int i;

	v = *(unsigned char *)s->addr & s->mask;
	v >>= s->shift;
	pos = SEG_POS(s);
	n = SEG_LEN(s);
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	for (i = 0; i < n; i++)
		buf[i] = Scoop_CharGlyphMap[SEG_TEXT(s)[(unsigned long)v * n + i]];
	buf[i] = 0;
	font = TextStyle_FontTable[s->style & 0x3f];
	pt.y -= 2;
	clip.x0 = pt.x;
	clip.x1 = pt.x + CalcTotalWidth(buf, font);
	clip.y0 = pt.y;
	clip.y1 = pt.y + GetCharHeight(font);
	DrawString(&clip, &pt, buf, font, 0xff, 0xf5);
}

void Scoop_EnvelopeCalc_Data(struct segrec *s)
{
	long font;
	int desc;
	unsigned char v;
	char buf[256];
	struct pt pt;
	struct rect clip;
	unsigned int pos;
	unsigned int n;
	unsigned int i;

	v = *(unsigned char *)s->addr & s->mask;
	v >>= s->shift;
	pos = SEG_POS(s);
	n = SEG_LEN(s);
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	for (i = 0; i < n; i++)
		buf[i] = Scoop_CharGlyphMap[SEG_TEXT(s)[(unsigned long)v * n + i]];
	buf[i] = 0;
	font = TextStyle_FontTable[s->style & 0x3f];
	pt.y -= 2;
	clip.x0 = pt.x;
	clip.x1 = pt.x + CalcTotalWidth(buf, font);
	clip.y0 = pt.y;
	desc = GetCharDescent(font);
	clip.y1 = pt.y + GetCharHeight(font) - desc;
	DrawString(&clip, &pt, buf, font, 0xff, 0xf5);
}
