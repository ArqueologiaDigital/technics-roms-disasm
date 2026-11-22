/* lane_p6 helper G, round 25r1, form b = p6_E_24r1m271b (run p6-r69) with the f_const numbering of form a
   (1 / 22 / 28 / 29: read with it, p6_E_24r1m271b matches the ROM through +52) and the default written LAST inside
   the switch: the ROM compares evt in place in XDE, V4.23 copied it to XWA first (form a: default after the
   switch).  p6_E_24r1m271b's header follows.
   lane_p6 helper E, round 24r1, form b = p6_C_23r1m271b with a no-code `&obj;` (the ROM spills obj to the frame's
   top slot, frame 178).  p6_C_23r1m271b's header follows.
   lane_p6 helper C, round 23r1, form b: module 271 (ui/ui_widget_defs.s), PsTrackSwitchProc, alternative to form a.
   Form b: the PARA_DRAW and SELE_DRAW cases keep their view pointer in a second variable `w` (the ROM homes it in
   the frame at +4, while the PAINT case keeps `v` in XIZ), the client box's mid line goes straight into a.y and
   b.y is copied from it, and the f_const objects are numbered 1-4 (arrays and the "%d" literal only, in case
   V4.23 lists an array's strings elsewhere).
*/
/* cc900-data: PsTrackSwitchProc 1 = PsTrkSw_AssignNamePtrs */
/* cc900-data: PsTrackSwitchProc 22 = PsTrkSw_SelectStateLabels */
/* cc900-data: PsTrackSwitchProc 28 = PsTrkSw_SelectStateColor */
/* cc900-data: PsTrackSwitchProc 29 = PsTrkSw_Confirm_DrawGeometry_Str_Fmtd */

#define EVT_PAINT                     0x1c0000bL
#define EVT_REPAINT                   0x1c0000cL
#define EVT_SELE_DRAW                 0x1c0000eL
#define EVT_PARA_DRAW                 0x1c0000fL
#define EVT_GET_CLASS                 0x1e00010L
#define EVT_CHECK_EDIT_SW             0x1e00053L
#define NAKA_CLASS_PsTrackSwitch      0x1600058L

struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
struct trsw { unsigned char pad[22]; unsigned int part; unsigned int *assign; unsigned int *value; int *state; };

extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern void GetBox(long, struct rect *);
extern void GetClientBox2(int, struct rect *, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawLine(struct pt *, struct pt *, int);
extern void DrawBox(struct rect *, int);
extern void DrawStringCentered(struct rect *, struct pt *, char *, long, int, int);
extern long PsTrackSwitchProc(long obj, long evt, long p);

long PsTrackSwitchProc(long obj, long evt, long p)
{
	struct rect box;
	struct rect cl;
	struct rect r2;
	struct pt c1;
	struct pt a;
	struct pt b;
	struct pt c2;
	char str[16];
	char *names[20] = { "RT1", "LFT", "RT2", "P 8", "P 9", "P10", "P11", "P12", "P 5", "P 6", "P 7", "P 4",
		"DRM", "CHD", "APC", "CTL", "RHY", "P13", "P14", "P15" };
	char *labels[5] = { "", "REC", "PLAY", "MUTE", "CLR" };
	int colors[5] = { 0xf5, 0x0a, 0x0d, 0xff, 0xff };
	struct trsw *w;
	struct trsw *v;
	unsigned int t;

	&obj;
	switch (evt) {
	case EVT_PAINT:
	case EVT_REPAINT:
		ViewableProc(obj, evt, p);
		v = GetViewInstance(obj);
		if (SendEvent(obj, EVT_GET_CLASS, 0) == NAKA_CLASS_PsTrackSwitch) {
			SendEvent(obj, EVT_PARA_DRAW, ((unsigned long)*v->assign << 16) + *v->value);
			SendEvent(obj, EVT_SELE_DRAW, *v->state);
		}
		return 0;
	case EVT_PARA_DRAW:
		w = GetViewInstance(obj);
		t = (unsigned int)(((unsigned long)p >> 16) & 0xffff);
		if (t != 0xffff)
			*w->assign = t;
		t = (unsigned int)p;
		if (t != 0xffff)
			*w->value = t;
		GetBox(obj, &box);
		GetClientBox2(0xcb, &box, &cl);
		r2 = cl;
		a.x = cl.x0;
		b.x = cl.x1;
		a.y = cl.y0 + (cl.y1 - cl.y0) / 2;
		b.y = a.y;
		cl.y1 = a.y - 1;
		r2.y0 = a.y + 1;
		GetBoxCenter(&cl, &c1);
		GetBoxCenter(&r2, &c2);
		Sprintf_Locked(str, "%d", w->part + 1);
		if (w->part < 8) {
			if (*w->assign != 0) {
				DrawDesignBox(&box, 0xcb, 0);
				DrawLine(&a, &b, 0);
				DrawStringCentered(&cl, &c1, str, 0L, 7, 0xf7);
				DrawBox(&r2, 7);
			} else {
				DrawDesignBox(&box, 0xcb, 7);
				DrawLine(&a, &b, 0);
				DrawStringCentered(&cl, &c1, str, 0L, 0, 0xf7);
			}
		} else {
			if (*w->assign != 0) {
				DrawDesignBox(&box, 0xcc, 7);
				DrawLine(&a, &b, 0);
				DrawBox(&cl, 0);
				DrawStringCentered(&cl, &c1, str, 0L, 7, 0xf7);
			} else {
				DrawDesignBox(&box, 0xcc, 7);
				DrawLine(&a, &b, 0);
				DrawStringCentered(&cl, &c1, str, 0L, 0, 0xf7);
			}
		}
		DrawStringCentered(&r2, &c2, names[*w->value], 0L, 0, 0xf7);
		return 0;
	case EVT_SELE_DRAW:
		w = GetViewInstance(obj);
		t = (unsigned int)p;
		if (t != 0xffff)
			*w->state = t;
		if (w->part < 8)
			box.y0 = 0x96;
		else
			box.y0 = 0xe3;
		box.x0 = (w->part & 7) * 40 + 2;
		box.x1 = box.x0 + 0x23;
		box.y1 = box.y0 + 0xb;
		GetBoxCenter(&box, &c1);
		DrawBox(&box, colors[*w->state]);
		DrawStringCentered(&box, &c1, labels[*w->state], 0L, 0, 0xf7);
		return 0;
	case EVT_CHECK_EDIT_SW:
		v = GetViewInstance(obj);
		if (v->part < 8) {
			if (v->part != p)
				return 0;
		} else if (v->part + 0x78 != p)
			return 0;
		return 1;
	default:
		return ViewableProc(obj, evt, p);
	}
}
