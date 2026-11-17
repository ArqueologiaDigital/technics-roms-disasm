/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_7m271b.c (2026-11-16-100-p6-r19)
   sha256 b105bdc9768abf6c347bf4c56cfd3cbd283ac78affe70f71666a6d74c1cf0680 (tar-sha256); compiled at -O3 -Xr
   cc900-name: sw_n7f=DrawEditSw_Str_N7f
   cc900-name: sw_n80=DrawEditSw_SelectVariantA_Str_N80
   cc900-name: sw_n81=DrawEditSw_SelectVariantC_Str_N81 */
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern char sw_n7f[], sw_n80[], sw_n81[];
extern char *__cdecl Strcpy(char *, char *);
void DrawEditSw(unsigned int sw)
{
	struct rect r;
	struct pt pt;
	char s[6];
	int w, hg;

	if (sw == 0xff || sw == 0xf) return;
	GetEditSwPoint(sw, &pt);
	if (pt.y != 0xef) {
		if (pt.x == 0) Strcpy(s, sw_n7f);
		else Strcpy(s, sw_n80);
	} else
		Strcpy(s, sw_n81);
	w = CalcTotalWidth(s, 0);
	hg = GetCharHeight(0);
	if (pt.x == 0) {
		r.x1 = -2;
		r.y1 = pt.y - hg / 2;
	}
	if (pt.x == 0x13f) {
		r.x1 = 0x13e - w;
		r.y1 = pt.y - hg / 2;
	}
	if (pt.y == 0xef) {
		r.x1 = pt.x - w / 2 - 1;
		r.y1 = 0xf5 - hg;
	}
	pt.x = r.x1 + 2;
	pt.y = r.y1 + 1;
	r.x2 = w + r.x1 + 1;
	r.y2 = hg + r.y1;
	DrawString(&r, &pt, s, 0, 0xf4, 0xf7);
}
