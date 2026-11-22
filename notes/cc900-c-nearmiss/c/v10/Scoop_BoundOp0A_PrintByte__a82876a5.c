/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_23r1m128b.c (2026-11-21-27-p6-r68)
   sha256 a82876a5e34b0277d0cf3c50bbc7966720ceff23fc50c0889a4f8fc6155a4f2e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: ScB3Fmt1d2=Scoop_EventLoop_36Entry_Branch3_Str_Fmt1d_2
   cc900-name: ScB3Fmt2d3=Scoop_EventLoop_36Entry_Branch3_Str_Fmt2d_3
   cc900-name: ScB3Fmt3d3=Scoop_EventLoop_36Entry_Branch3_Str_Fmt3d_3 */
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
extern struct rect Scoop_BoundOp0A_ClipBox;
extern long TextStyle_NibbleFontTable[];
extern char ScB3Fmt1d2[];
extern char ScB3Fmt2d3[];
extern char ScB3Fmt3d3[];
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
void Scoop_BoundOp0A_PrintByte(unsigned char *s)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	int *p;
	unsigned char type;

	box = Scoop_BoundOp0A_ClipBox;
	p = (int *)*(unsigned int *)(s + 2);
	type = s[11];
	pt.x = *(int *)(s + 7);
	pt.y = *(int *)(s + 9);
	switch (type) {
	case 1:
		Sprintf_Locked(buf, ScB3Fmt1d2, *p);
		break;
	case 2:
		Sprintf_Locked(buf, ScB3Fmt2d3, *p);
		break;
	default:
		Sprintf_Locked(buf, ScB3Fmt3d3, *p);
		break;
	}
	DrawString(&box, &pt, buf, TextStyle_NibbleFontTable[s[6] & 15], 0xff, 0xf5);
}
