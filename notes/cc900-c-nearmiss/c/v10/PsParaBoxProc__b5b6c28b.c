/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_5m271b.c (2026-11-16-92-p6-r18)
   sha256 b5b6c28bf49d741d38317e0e5f799913d2a958b71d42363aad1e728d1b16e994 (tar-sha256); compiled at -O3 -XS -Xr */
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_GET_STRING        0x1e0003aL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct rbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	unsigned int swid; int *value; unsigned int sub;
};
extern long VwBoxProc(long, long, long);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern void *GetViewInstance(long);
extern void DrawStringAlignment(struct rect *, struct pt *, char *, long, int, int, int);
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
long PsParaBoxProc(long obj, long evt, long p)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	struct rbinst *h;

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
		DrawStringAlignment(&box, &pt, buf, h->font, h->i32, h->i22, h->b34);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	}
	return VwBoxProc(obj, evt, p);
}
