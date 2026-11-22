/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_E_24r1m128b.c (2026-11-22-1-p6-r69)
   sha256 833bebbd8bbc33acbb4f6da3b0d62c85bc1cbf3be8f63616b65b98771909dcc8 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Scoop_BoundOp07_DrawStrByField=Scoop_BoundOp07_DrawStringByField */
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
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
