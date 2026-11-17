/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_window_procs_m0.c (2026-11-16-91-p6-r17)
   sha256 673a0bdd99ca13a8eb59016c71b237363a68b5f1e69b1663f321559090ba0eb2 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void *GetViewInstance(long);
#define EVT_DRAW              0x1c0000dL
struct rect { int x1, y1, x2, y2; };
extern long ViewableProc(long, long, long);
struct pt { int x, y; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
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
