/* lane_p6 helper E, round 24r1, form b (text pointer reloaded into p in the loop): module 128 (display/scoop_display.s), one-spot retries of run p6-r68's near
   misses Scoop_CurveUpdate_SegmentEnd and Scoop_EnvelopeCalc_Data (+2), from p6_C_23r1m128a (the -Xr listing closest
   to the ROM: s in XBC, i in IY, push XIZ).  What the ROM shows and this form changes:
   - frame: font and v are spilled (sharing slots: in the twin v shares desc's), buf lowest of the address-taken
     locals and clip highest, so clip, pt, buf are declared in that order (reverse declaration order);
   - the record fields from +7 sit at odd offsets: 23r1's `rest[8]` array was padded to +8 by V4.23, so the tail is
     now one byte array from +6 (style, then the far text pointer +7, length +11, cell +13);
   - the ROM loads the near address (XIZ), the mask (L) and the shift (E) before the `and`: three locals p, mask,
     shift, whose registers pos (HL) and n (DE) reuse;
   - the glyph row is indexed by the 32-bit `mul xwa,de` product plus the extended i: `(unsigned long)(v * n) + i`.
   Form b: form a with the text pointer reloaded into p at the top of the loop (the ROM loads it into XIZ first).
   Form c: form a with the three DrawString register arguments in pointer locals assigned just before the call (the
   ROM computes &clip, &pt, buf into XHL / XBC / XDE before the pushes).
   The record: +2 a near address whose byte is masked (+4) and shifted (+5) into a row number, +6 a font style
   (low 6 bits index TextStyle_FontTable), +7 a far pointer to rows of glyph codes, +11 the row length, +13 a text cell
   (row = cell / 40, x = (cell % 40) * 8).  The row is translated through Scoop_CharGlyphMap and drawn with DrawString
   clipped to its own width / height, two pixels higher.
   cc900-options: -Xr
*/

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
extern int GetCharDescent(long);
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

void Scoop_EnvelopeCalc_Data(struct segrec *s)
{
	long font;
	int desc;
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
	desc = GetCharDescent(font);
	clip.y1 = pt.y + GetCharHeight(font) - desc;
	DrawString(&clip, &pt, buf, font, 0xff, 0xf5);
}

/* Scoop_BoundOp07_DrawStringByField: form a's spelling with the text pointer reloaded into p in the loop.
   cc900-name: Scoop_BoundOp07_DrawStrByField=Scoop_BoundOp07_DrawStringByField */
extern struct rect Scoop_BoundOp07_ClipBox;
extern long TextStyle_NibbleFontTable[];

void Scoop_BoundOp07_DrawStrByField(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	unsigned char *p;
	unsigned char mask;
	unsigned char shift;
	unsigned char idx;
	unsigned int n;
	unsigned int i;
	long font;

	box = Scoop_BoundOp07_ClipBox;
	p = (unsigned char *)*(unsigned int *)(s + 2);
	mask = s[4];
	shift = s[5];
	idx = *p & mask;
	idx >>= shift;
	pt.x = *(int *)(s + 13);
	pt.y = *(int *)(s + 15);
	n = *(unsigned int *)(s + 11);
	for (i = 0; i < n; i++) {
		p = *(unsigned char **)(s + 7);
		buf[i] = p[(unsigned long)(idx * n) + i];
	}
	buf[i] = 0;
	font = TextStyle_NibbleFontTable[s[6] & 15];
	DrawString(&box, &pt, buf, font, 0xff, 0xf5);
}
