/* Probe round 36r1, helper C, form b (EV_HIDE reuses v instead of a second local q): audio/presentation_sound_nav.s (module 271), the xr_screen.py shape at -O3 -Xr.
   ScreenProc(obj, evt, p): the NAKA "Screen" class (parent GroupBox; instance +26 exit title, +30 window link).
   EV_SHOW walks to the innermost child window, hides every non-Screen target, clears the window link for show
   reasons 0 / 3 / 5, sets the wallpaper and colour from the box (main task asleep while the title posts), sets the
   title's return screen, forwards to GroupBoxProc and re-sends to the child window on reason 4.  EV_HIDE clears the
   link (reasons 0 / 4 / 5), EV_SW_OFF updates the screen, EV_SW_IN with switch 15 and no IvExit child leaves an
   interrupt title or changes to the exit title.  p is a `register` parameter (XIZ); v (frame +4) the instance.
   Switch cases in reverse ROM compare order (V4.23 compares them last to first), default first. */
/* cc900-module: GroupBoxProc PostTitle_Function SetWallPaper SetWallColor */

#define EVT_SHOW               0x1c00001L
#define EVT_HIDE               0x1c00002L
#define EVT_SW_IN              0x1c00007L
#define EVT_SW_OFF             0x1c00009L
#define EVT_DRAW               0x1c0000dL
#define EVT_CHANGE_TITLE       0x1c00015L
#define EVT_CHECK_CLASS        0x1e00014L
#define EVT_SEARCH_CLASS       0x1e00024L
#define EVT_SET_PARENT_WINDOW  0x1e00048L
#define EVT_SET_CHILD_WINDOW   0x1e00049L
#define EVT_GET_PARENT_WINDOW  0x1e0004aL
#define EVT_GET_CHILD_WINDOW   0x1e0004bL
#define EVT_SET_RETURN_SCREEN  0x1e00077L
#define EVT_INTERRUPT_EXIT     0x1e00079L
#define EVT_IS_INTERRUPT       0x1e0007aL
#define EVT_SET_HOLD           0x1e0009aL
#define EVT_GET_BOX_BORDER     0x1e000b1L
#define EVT_GET_BOX_COLOR      0x1e000b2L
#define NAKA_CLASS_Screen      0x1600033L
#define NAKA_CLASS_IvExit      0x1600047L
#define TITLE_PS               0x1a00000L

struct scr { unsigned char pad[26]; long exit; long *win; };

extern long SendEvent(long, long, long);
extern struct scr *GetViewInstance(long);
extern long GetCurrentTarget(void);
extern void SetCurrentTarget(long);
extern long GetTitleNow(void);
extern int PostTitle_Function(void);
extern void SleepMainTask(void);
extern void WakeUpMainTask(void);
extern void SetWallPaper(int);
extern void SetWallColor(int);
extern void DrawWall(void);
extern void SetNeedUpdate(int);
extern void UpdateScreen(void);
extern long GroupBoxProc(long, long, long);
extern long ScreenProc(long obj, long evt, long p);

long ScreenProc(long obj, long evt, register long p)
{
	struct scr *v;
	long w;

	switch (evt) {
	default:
		return GroupBoxProc(obj, evt, p);
	case EVT_SHOW:
		while ((w = SendEvent(GetCurrentTarget(), EVT_GET_CHILD_WINDOW, 0)) != -1)
			SetCurrentTarget(w);
		if (SendEvent(GetCurrentTarget(), EVT_CHECK_CLASS, NAKA_CLASS_Screen) == 0)
			do
				SendEvent(-1, EVT_HIDE, p);
			while (SendEvent(GetCurrentTarget(), EVT_CHECK_CLASS, NAKA_CLASS_Screen) == 0);
		SendEvent(-1, EVT_HIDE, p);
		v = GetViewInstance(obj);
		switch (p) {
		case 0:
		case 5:
		case 3:
			*v->win = -1;
			break;
		case 4:
			break;
		}
		if (PostTitle_Function() != 0)
			SleepMainTask();
		SetWallPaper((int)SendEvent(obj, EVT_GET_BOX_BORDER, 0));
		SetWallColor((int)SendEvent(obj, EVT_GET_BOX_COLOR, 0));
		if (PostTitle_Function() != 0)
			WakeUpMainTask();
		SendEvent(GetTitleNow(), EVT_SET_RETURN_SCREEN, obj);
		GroupBoxProc(obj, evt, p);
		if (p == 4 && *v->win != -1)
			SendEvent(*v->win, evt, p);
		break;
	case EVT_HIDE:
		GroupBoxProc(obj, evt, p);
		v = GetViewInstance(obj);
		switch (p) {
		case 0:
		case 5:
		case 4:
			*v->win = -1;
			break;
		case 3:
			break;
		}
		break;
	case EVT_DRAW:
		DrawWall();
		break;
	case EVT_SW_OFF:
		GroupBoxProc(obj, evt, p);
		SetNeedUpdate(1);
		UpdateScreen();
		SetNeedUpdate(0);
		break;
	case EVT_SW_IN:
		v = GetViewInstance(obj);
		if (SendEvent(obj, EVT_SEARCH_CLASS, NAKA_CLASS_IvExit) == 0 && p == 15) {
			if (SendEvent(GetTitleNow(), EVT_IS_INTERRUPT, 0) != 0) {
				SendEvent(GetTitleNow(), EVT_INTERRUPT_EXIT, 0);
				SendEvent(GetTitleNow(), EVT_SET_HOLD, 0);
			} else if (v->exit != TITLE_PS)
				SendEvent(-1, EVT_CHANGE_TITLE, v->exit);
		}
		return GroupBoxProc(obj, evt, p);
	case EVT_SET_CHILD_WINDOW:
		*GetViewInstance(obj)->win = p;
		break;
	case EVT_GET_CHILD_WINDOW:
		return *GetViewInstance(obj)->win;
	case EVT_SET_PARENT_WINDOW:
		break;
	case EVT_GET_PARENT_WINDOW:
		return -1;
	}
	return 0;
}
