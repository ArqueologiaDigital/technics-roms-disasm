/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_23r1m128b.c (2026-11-21-27-p6-r68)
   sha256 a82876a5e34b0277d0cf3c50bbc7966720ceff23fc50c0889a4f8fc6155a4f2e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: ScB3Fmt1d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d
   cc900-name: ScB3Fmt2d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d
   cc900-name: ScB3Fmt2d2=Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_2
   cc900-name: ScB3Fmt3d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d
   cc900-name: ScB3Fmt3d2=Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_2
   cc900-name: ScB3Fmt4d=Scoop_EventLoop_36Entry_Branch3_Str_Fmt4d */
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
extern struct rect GUI_FormatStrings;
extern long TextStyle_NibbleFontTable[];
extern char ScB3Fmt1d[];
extern char ScB3Fmt2d[];
extern char ScB3Fmt3d[];
extern char ScB3Fmt2d2[];
extern char ScB3Fmt3d2[];
extern char ScB3Fmt4d[];
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
void Scoop_BoundOp0B_PrintSignedField(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	unsigned char v;
	unsigned char type;
	unsigned char c;

	box = GUI_FormatStrings;
	v = (*(unsigned char *)*(unsigned int *)(s + 2) & s[4]) >> s[5];
	type = s[11];
	pt.x = *(int *)(s + 7);
	pt.y = *(int *)(s + 9);
	c = s[12];
	if (c != v) {
		if (c < 128 && v >= 128) {
			c = 128;
			v -= 128;
		}
		if (v > c) {
			buf[0] = '+';
			v -= c;
		} else {
			buf[0] = '-';
			v = c - v;
		}
		switch (type) {
		case 1:
			Sprintf_Locked(buf + 1, ScB3Fmt1d, v);
			break;
		case 2:
			Sprintf_Locked(buf + 1, ScB3Fmt2d, v);
			break;
		default:
			Sprintf_Locked(buf + 1, ScB3Fmt3d, v);
			break;
		}
	} else {
		v = 0;
		switch (type) {
		case 1:
			Sprintf_Locked(buf, ScB3Fmt2d2, v);
			break;
		case 2:
			Sprintf_Locked(buf, ScB3Fmt3d2, v);
			break;
		default:
			Sprintf_Locked(buf, ScB3Fmt4d, v);
			break;
		}
	}
	DrawString(&box, &pt, buf, TextStyle_NibbleFontTable[s[6] & 15], 0xff, 0xf5);
}
