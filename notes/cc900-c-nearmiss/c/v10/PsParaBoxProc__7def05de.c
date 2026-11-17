/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_4m271a.c (2026-11-16-88-p6-r16)
   sha256 7def05de68d517cff8c26389ffa6f51bdc61ce5fd0d9a82f01750e63615d7417 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_GET_STRING        0x1e0003aL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct pbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	long func; void *value;
};
extern long VwBoxProc(long, long, long);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern void DrawStringAlignment(struct rect *, struct pt *, char *, int, int, int, long);
extern char *__cdecl Strcpy(char *, char *);
long PsParaBoxProc(long obj, long evt, long p)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	struct pbinst *h;

	switch (evt) {
	case EVT_PARA_DRAW:
		VwBoxProc(obj, evt, p);
		GetClientBox(obj, &box);
		GetBoxCenter(&box, &pt);
		h = GetViewInstance(obj);
		if (p == 0) {
			SendEvent(obj, EVT_GET_STRING, (long)buf);
			if (buf[0] == 0) return 0;
		} else
			Strcpy(buf, (char *)p);
		DrawStringAlignment(&box, &pt, buf, h->b34, h->i22, h->i32, h->font);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	}
	return VwBoxProc(obj, evt, p);
}
