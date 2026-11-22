/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_23r1m128b.c (2026-11-21-27-p6-r68)
   sha256 a82876a5e34b0277d0cf3c50bbc7966720ceff23fc50c0889a4f8fc6155a4f2e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: ScFmt1d=Scoop_EventLoop_36Entry_Str_Fmt1d
   cc900-name: ScFmt2dB1=Scoop_EventLoop_36Entry_Branch1_Str_Fmt2d
   cc900-name: ScFmt3dB2=Scoop_EventLoop_36Entry_Branch2_Str_Fmt3d */
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
extern struct rect Scoop_BoundOp06_ClipBox;
extern long TextStyle_FontTable[];
extern char ScFmt1d[];
extern char ScFmt2dB1[];
extern char ScFmt3dB2[];
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern int CalcTotalWidth(char *, long);
extern int GetCharDescent(long);
extern int GetCharHeight(long);
void Scoop_EventLoop_36Entry(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	long font;
	int *p;
	unsigned int pos;
	unsigned char type;
	int d;

	box = Scoop_BoundOp06_ClipBox;
	p = (int *)*(unsigned int *)(s + 2);
	pos = *(unsigned int *)(s + 7);
	type = s[9];
	pt.y = pos / 40;
	pt.x = (pos - pt.y * 40) * 8;
	pt.y -= 2;
	switch (type) {
	case 1:
		Sprintf_Locked(buf, ScFmt1d, *p);
		break;
	case 2:
		Sprintf_Locked(buf, ScFmt2dB1, *p);
		break;
	default:
		Sprintf_Locked(buf, ScFmt3dB2, *p);
		break;
	}
	font = TextStyle_FontTable[s[6] & 0x3f];
	box.x0 = pt.x;
	box.x1 = pt.x + CalcTotalWidth(buf, font);
	box.y0 = pt.y + 2;
	d = GetCharDescent(font);
	box.y1 = pt.y + GetCharHeight(font) - d;
	DrawString(&box, &pt, buf, font, 0xff, 0xf5);
}
