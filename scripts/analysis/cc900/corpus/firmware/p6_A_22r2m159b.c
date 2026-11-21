/* lane_p6 helper A, round 22r2, form b: module 159 (audio/sound_editor_ui.s), alternatives to form a.
   StylCnvStorBnk_ProcDataBlock: the ROM keeps the view pointer both in XIZ and in a frame slot and reads tail_x /
   tail_y through the frame copy, so form b reads those two through a second pointer variable.
   CmpNameMenuBoxProc: `if (evt == EVT_DRAW) { ... } return InheritedProc(...)` order.
   PsStylCnvVerProc: SHOW and HIDE share one case body.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PaintArrow_DrawFilled PaintArrow_DrawOutline */

#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_DRAW              0x1c0000dL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_GET_STR_PTR       0x1e00089L

struct rect { int x0, y0, x1, y1; };
struct arrowinst { unsigned char pad[22]; int colour; int frame_only; int direction; int tail_x; int tail_y; };

extern unsigned char __near STYLE_SECTION;
extern char __near ram_3f68[];

extern long InheritedProc(long, long, long);
extern void *GetViewInstance(long);
extern void GetClientBox(long, struct rect *);
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern void PaintArrow_DrawOutline(struct rect *, int, int, int, int);
extern void PaintArrow_DrawFilled(struct rect *, int, int, int, int);

long StylCnvStorBnk_ProcDataBlock(long obj, long evt, long p)
{
	struct arrowinst *v;
	struct arrowinst *w;
	struct rect box;

	if (evt == EVT_PAINT) {
		InheritedProc(obj, evt, p);
		v = GetViewInstance(obj);
		w = v;
		GetClientBox(obj, &box);
		if (v->frame_only)
			PaintArrow_DrawOutline(&box, v->colour, w->tail_x, v->direction, w->tail_y);
		else
			PaintArrow_DrawFilled(&box, v->colour, w->tail_x, v->direction, w->tail_y);
		return 0;
	}
	return InheritedProc(obj, evt, p);
}

long CmpNameMenuBoxProc(long obj, long evt, long p)
{
	if (evt == EVT_DRAW) {
		if (STYLE_SECTION < 12) {
			InheritedProc(obj, evt, p);
			SendEvent(obj, EVT_PARA_DRAW, 0L);
		}
		return 0;
	}
	return InheritedProc(obj, evt, p);
}

long PsStylCnvVerProc(long obj, long evt, long p)
{
	char buf[512];

	switch (evt) {
	default:
		return InheritedProc(obj, evt, p);
	case EVT_HIDE:
	case EVT_SHOW:
		InheritedProc(obj, evt, p);
		break;
	case EVT_GET_STR_PTR:
		return (long)ram_3f68;
	case EVT_PAINT:
	case EVT_REPAINT:
		InheritedProc(obj, evt, p);
		Strcpy(buf, ram_3f68);
		SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		break;
	}
	return 0;
}
