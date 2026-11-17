/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_5a.c (2026-11-16-45-p6-r9)
   sha256 0a24d3abb3ad01135d3ba1544257bdeae1dc14fc21da9794d409ad64bba47312 (tar-sha256); compiled at -O3 -Xr */
struct view { unsigned char pad[14]; unsigned char box[8]; int f22; int f24; };
extern long ViewableProc(long, long, long);
extern struct view *GetViewInstance(long);
extern void DrawDesignBox(unsigned char *, int, int);
long BoxProc(long obj, long evt, long p)
{
	struct view *h;
	long off;

	switch (evt) {
	case 0x1c0000dL:
		ViewableProc(obj, evt, p);
		h = GetViewInstance(obj);
		DrawDesignBox(h->box, h->f24, h->f22);
		return 0;
	case 0x1e000b1L:
		off = 0x18;
		goto rd;
	case 0x1e000b2L:
		off = 0x16;
	rd:
		return *(int *)((unsigned char *)GetViewInstance(obj) + off);
	}
	return ViewableProc(obj, evt, p);
}
