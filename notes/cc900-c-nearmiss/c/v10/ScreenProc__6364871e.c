/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_36r1m271a.c (2026-11-22-25-p6-r92)
   sha256 6364871e387ea4b3ad14a16382ec9944e49db131823338949f481f921b80b1f9 (tar-sha256); compiled at -O3 -Xr */
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
long ScreenProc(long obj, long evt, register long p)
{
	struct scr *v;
	struct scr *q;
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
		q = GetViewInstance(obj);
		switch (p) {
		case 0:
		case 5:
		case 4:
			*q->win = -1;
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
