/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m159a.c (2026-11-21-21-p6-r66)
   sha256 00429c61ba422c3b11308126fa37b7fcc6c8dc1a2657aca7382a2a809dc2c280 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_PAINT             0x1c0000bL
struct rect { int x0, y0, x1, y1; };
struct arrowinst { unsigned char pad[22]; int colour; int frame_only; int direction; int tail_x; int tail_y; };
extern long InheritedProc(long, long, long);
extern void *GetViewInstance(long);
extern void GetClientBox(long, struct rect *);
extern void PaintArrow_DrawOutline(struct rect *, int, int, int, int);
extern void PaintArrow_DrawFilled(struct rect *, int, int, int, int);
long StylCnvStorBnk_ProcDataBlock(long obj, long evt, long p)
{
	struct arrowinst *v;
	struct rect box;

	if (evt != EVT_PAINT)
		return InheritedProc(obj, evt, p);
	InheritedProc(obj, evt, p);
	v = GetViewInstance(obj);
	GetClientBox(obj, &box);
	if (v->frame_only != 0)
		PaintArrow_DrawOutline(&box, v->colour, v->tail_x, v->direction, v->tail_y);
	else
		PaintArrow_DrawFilled(&box, v->colour, v->tail_x, v->direction, v->tail_y);
	return 0;
}
