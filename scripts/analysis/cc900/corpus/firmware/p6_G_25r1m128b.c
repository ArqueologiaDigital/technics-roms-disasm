/* lane_p6 helper G, round 25r1, form b (form a's notes below; this form: the curve pair without p / m / sh, i.e.
   p6_C_23r1m128b with only the byte offsets and the clip / pt / buf order changed; BoundOp07 with i and n declared
   before p / m / sh).
   lane_p6 helper G, round 25r1, form a: module 128 (display/scoop_display.s), one-spot retries of run p6-r68's
   Scoop near misses (+2): Scoop_CurveUpdate_SegmentEnd and Scoop_EnvelopeCalc_Data (from p6_C_23r1m128b, -Xr) and
   Scoop_BoundOp07_DrawStringByField (from p6_D_23r1m128b, -Xr).
   The ROM is the -Xr shape (no loop hoisting: the row pointer is reloaded into XIZ every iteration; pt.y stored and
   reloaded; frame-address arguments through XWA), with the record in XBC / XDE, the loop index and count in
   registers, and the masked byte computed from three values loaded first: the byte's address into XIZ, the mask
   into L, the shift into E / C, then `ld a,(xiz); and a,l`, the byte kept in the frame.  So:
   - the byte's address, mask and shift are locals assigned first (p, m, sh), and p is reused as the row pointer
     inside the loop (XIZ in both places, pushed once);
   - the record fields at odd offsets are read by byte offset (p6_C_23r1m128b's struct put `rest` at +8, so its
     words came from +8 / +12 / +14 instead of +7 / +11 / +13);
   - the curve pair declares clip, pt, buf in that order (the ROM has buf lowest, then pt, then clip).
   Form b: the curve pair without p / m / sh (offsets and order only); BoundOp07 with i and n declared before p.
   cc900-options: -Xr
*/

struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };

#define SEG_ADDR(s)	(*(unsigned int *)((unsigned char *)(s) + 2))
#define SEG_TEXT(s)	(*(unsigned char **)((unsigned char *)(s) + 7))
#define SEG_LEN(s)	(*(unsigned int *)((unsigned char *)(s) + 11))
#define SEG_POS(s)	(*(unsigned int *)((unsigned char *)(s) + 13))

extern unsigned char Scoop_CharGlyphMap[];
extern long TextStyle_FontTable[];
extern long TextStyle_NibbleFontTable[];
extern struct rect Scoop_BoundOp07_ClipBox;
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);

void Scoop_CurveUpdate_SegmentEnd(unsigned char *s)
{
	struct rect clip;
	struct pt pt;
	char buf[256];
	long font;
	unsigned char v;
	unsigned int pos;
	unsigned int n;
	unsigned int i;

	v = *(unsigned char *)SEG_ADDR(s) & s[4];
	v >>= s[5];
	pos = SEG_POS(s);
	n = SEG_LEN(s);
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	for (i = 0; i < n; i++)
		buf[i] = Scoop_CharGlyphMap[SEG_TEXT(s)[(unsigned long)v * n + i]];
	buf[i] = 0;
	font = TextStyle_FontTable[s[6] & 0x3f];
	pt.y -= 2;
	clip.x0 = pt.x;
	clip.x1 = pt.x + CalcTotalWidth(buf, font);
	clip.y0 = pt.y;
	clip.y1 = pt.y + GetCharHeight(font);
	DrawString(&clip, &pt, buf, font, 0xff, 0xf5);
}

void Scoop_EnvelopeCalc_Data(unsigned char *s)
{
	struct rect clip;
	struct pt pt;
	char buf[256];
	long font;
	int desc;
	unsigned char v;
	unsigned int pos;
	unsigned int n;
	unsigned int i;

	v = *(unsigned char *)SEG_ADDR(s) & s[4];
	v >>= s[5];
	pos = SEG_POS(s);
	n = SEG_LEN(s);
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	for (i = 0; i < n; i++)
		buf[i] = Scoop_CharGlyphMap[SEG_TEXT(s)[(unsigned long)v * n + i]];
	buf[i] = 0;
	font = TextStyle_FontTable[s[6] & 0x3f];
	pt.y -= 2;
	clip.x0 = pt.x;
	clip.x1 = pt.x + CalcTotalWidth(buf, font);
	clip.y0 = pt.y;
	desc = GetCharDescent(font);
	clip.y1 = pt.y + GetCharHeight(font) - desc;
	DrawString(&clip, &pt, buf, font, 0xff, 0xf5);
}

void Scoop_BoundOp07_DrawStringByField(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	unsigned char idx;
	unsigned int i;
	unsigned int n;
	unsigned char *p;
	unsigned char m;
	unsigned char sh;

	box = Scoop_BoundOp07_ClipBox;
	p = (unsigned char *)SEG_ADDR(s);
	m = s[4];
	sh = s[5];
	idx = *p & m;
	idx >>= sh;
	pt.x = *(int *)(s + 13);
	pt.y = *(int *)(s + 15);
	n = SEG_LEN(s);
	for (i = 0; i < n; i++) {
		p = SEG_TEXT(s);
		buf[i] = p[idx * n + i];
	}
	buf[i] = 0;
	DrawString(&box, &pt, buf, TextStyle_NibbleFontTable[s[6] & 15], 0xff, 0xf5);
}
