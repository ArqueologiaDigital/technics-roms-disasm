/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_2a.c (2026-11-16-68-p6-r12)
   sha256 142b615fa87d9a2c1a23991cd35a1c56f44c514ada1d12b5095f91c20ccc177a (tar-sha256); compiled at -O3 -Xr */
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawBitmap(struct pt *, unsigned char *);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strcat(char *, char *);
extern unsigned char *FDemo_LinkedListLookupField(char *);
extern void DrawBitmapFile(struct pt *, unsigned char *);
extern void ChangePalette(int);
extern char VwUserBitmapByName_Str_BmpExt[];
long VwUserBitmapByNameProc(long obj, long evt, long p)
{
	struct pt pt;
	char name[16];
	struct vinst *h;
	unsigned char *f;

	switch (evt) {
	case EVT_SHOW:
		ViewableProc(obj, evt, p);
		return 0;
	case EVT_DRAW:
		ViewableProc(obj, evt, p);
		h = GetViewInstance(obj);
		pt.x = h->r.x1;
		pt.y = h->r.y1;
		Strcpy(name, (char *)h->l22);
		Strcat(name, VwUserBitmapByName_Str_BmpExt);
		f = FDemo_LinkedListLookupField(name);
		if (f != 0) DrawBitmapFile(&pt, f);
		else DrawBitmap(&pt, 0);
		return 0;
	case EVT_HIDE:
		ChangePalette(2);
		ViewableProc(obj, evt, p);
		return 0;
	}
	return ViewableProc(obj, evt, p);
}
