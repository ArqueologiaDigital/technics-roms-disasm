/* Probe round 36r1, helper C, form a: audio/semenu_routines.s (module 129), the xr_screen.py shape at -O3 -Xr.
   SeMenu_DrawKeyScaleGraph(base, mode): clear the graph box, read the key-scale depth (part param 10) and the break
   point note(s) (params base..base+2; one only when mode == 1), turn them into keyboard x positions (+48), then draw
   the flat line (depth 0) or the sloped segments, and the dotted verticals at the left, centre and right points.
   Frame (last declared lowest): lo +4, hi +6, dl +8, dr +10, xh +12, x +14, xl +16, depth +18, ad +20, n3 +22,
   n1 +24, n2 +26; y1 / y2 are `register` (IZ / QIZ); s, a, b are `register` scratch values. */
/* cc900-module: SeMenu_LoadPartParam SeMenu_NoteToKeyboardX SeMenu_StoreAbsoluteValue */

extern void __cdecl SeMenu_ClearRect(unsigned int, unsigned int, unsigned int, unsigned int);
extern void __cdecl SeGfx_DrawLine(unsigned int, unsigned int, unsigned int, unsigned int);
extern void __cdecl SeMenu_DrawDottedLine(unsigned int, unsigned int, unsigned int, unsigned int);
extern void SeMenu_LoadPartParam();
extern void SeMenu_NoteToKeyboardX();
extern void SeMenu_StoreAbsoluteValue();
extern void SeMenu_DrawKeyScaleGraph(unsigned char base, unsigned char mode);

void SeMenu_DrawKeyScaleGraph(unsigned char base, unsigned char mode)
{
	unsigned char n2;
	unsigned char n1;
	unsigned char n3;
	unsigned char ad;
	signed char depth;
	unsigned int xl;
	unsigned int x;
	unsigned int xh;
	int dr;
	int dl;
	unsigned int hi;
	unsigned int lo;
	register int y1;
	register int y2;
	register unsigned int s;
	register int a;
	register int b;

	SeMenu_ClearRect(48, 73, 254, 121);
	SeMenu_LoadPartParam(10, &depth);
	if (mode == 1) {
		SeMenu_LoadPartParam(base, &n1);
		SeMenu_NoteToKeyboardX(n1, &x);
		x += 48;
		xl = 48;
		lo = 48;
		xh = 254;
		hi = 254;
		dl = x - lo;
		dr = hi - x;
	} else {
		SeMenu_LoadPartParam(base, &n1);
		SeMenu_LoadPartParam((unsigned char)(base + 1), &n2);
		SeMenu_LoadPartParam((unsigned char)(base + 2), &n3);
		SeMenu_NoteToKeyboardX(n1, &x);
		SeMenu_NoteToKeyboardX(n2, &xl);
		SeMenu_NoteToKeyboardX(n3, &xh);
		x += 48;
		xl += 48;
		xh += 48;
		if (xl > x)
			xl = x - 1;
		if (x > xh)
			xh = x + 1;
		lo = xl;
		hi = xh;
		dl = x - lo;
		dr = hi - x;
	}
	if (depth == 0) {
		SeGfx_DrawLine(48, 97, 254, 97);
		SeMenu_DrawDottedLine(x, 97, x, 121);
		SeMenu_DrawDottedLine(lo, 97, lo, 121);
		SeMenu_DrawDottedLine(hi, 97, hi, 121);
		return;
	}
	SeMenu_StoreAbsoluteValue(depth, &ad);
	s = 25;
	s = (int)s * 50 / ad;
	a = dl * ad / 50;
	b = dr * ad / 50;
	y1 = 97;
	y2 = 97;
	if (dl > s) {
		y1 = depth < 0 ? 72 : 122;
		xl = x - s;
	} else if (depth >= 0)
		y1 += a;
	else
		y1 -= a;
	if (dr > s) {
		y2 = depth < 0 ? 122 : 72;
		xh = x + s;
	} else if (depth >= 0)
		y2 -= b;
	else
		y2 += b;
	SeGfx_DrawLine(48, y1, xl, y1);
	SeGfx_DrawLine(xl, y1, xh, y2);
	SeGfx_DrawLine(xh, y2, 254, y2);
	SeMenu_DrawDottedLine(x, 97, x, 121);
	SeMenu_DrawDottedLine(lo, y1, lo, 121);
	SeMenu_DrawDottedLine(hi, y2, hi, 121);
}
