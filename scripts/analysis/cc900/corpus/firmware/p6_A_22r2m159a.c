/* lane_p6 helper A, round 22r2, form a: module 159 (audio/sound_editor_ui.s), the roots inside pool roots23_A's
   PaintArrow_DrawOutline stretch: the paint proc of the arrow widget (StylCnvStorBnk_ProcDataBlock), the
   composer-name menu box, eight *LangCheck language-table functions (the FtLangText shape of
   flash_floppy_handlers_m0.c) and the style-convert version text box.
   Form a: `if (evt != X) return InheritedProc(...)` for the two-way procs; PsStylCnvVerProc's switch in reverse
   ROM compare order (V4.23 compares case labels in reverse source order), default first.
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
#define EVT_GET_LANGUAGE_PTR  0x1e0009fL

struct rect { int x0, y0, x1, y1; };
struct arrowinst { unsigned char pad[22]; int colour; int frame_only; int direction; int tail_x; int tail_y; };

extern unsigned char __near STYLE_SECTION;
extern char __near ram_3f68[];
extern long AttLangCheck_PtrTable[];
extern long SureLangCheck_PtrTable[];
extern long SndMemLangCheck_PtrTable[];
extern long SndMem1LangCheck_PtrTable[];
extern long MemfulLangCheck_PtrTable[];
extern long Memful2LangCheck_PtrTable[];
extern long StylCnvLangCheck_PtrTable[];
extern long Hama_ModeInit_Table[];

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

long CmpNameMenuBoxProc(long obj, long evt, long p)
{
	if (evt != EVT_DRAW)
		return InheritedProc(obj, evt, p);
	if (STYLE_SECTION < 12) {
		InheritedProc(obj, evt, p);
		SendEvent(obj, EVT_PARA_DRAW, 0L);
	}
	return 0;
}

long AttLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)AttLangCheck_PtrTable;
	return 0;
}

long SureLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)SureLangCheck_PtrTable;
	return 0;
}

long SndMemLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)SndMemLangCheck_PtrTable;
	return 0;
}

long SndMem1LangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)SndMem1LangCheck_PtrTable;
	return 0;
}

long MemfulLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)MemfulLangCheck_PtrTable;
	return 0;
}

long Memful2LangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)Memful2LangCheck_PtrTable;
	return 0;
}

long StylCnvLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)StylCnvLangCheck_PtrTable;
	return 0;
}

long SndArrLangCheck(long obj, long evt)
{
	if (evt == EVT_GET_LANGUAGE_PTR) return (long)Hama_ModeInit_Table;
	return 0;
}

long PsStylCnvVerProc(long obj, long evt, long p)
{
	char buf[512];

	switch (evt) {
	default:
		return InheritedProc(obj, evt, p);
	case EVT_SHOW:
		InheritedProc(obj, evt, p);
		break;
	case EVT_HIDE:
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
