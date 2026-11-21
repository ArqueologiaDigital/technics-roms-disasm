/* lane_p6 helper A, round 22r2, form b: module 271 (ui/ui_widget_defs.s), AcTrackSwitchProc, alternative to form a.
   Form b: the SW_IN case tests the CHECK_EDIT_SW answer as true first; the part-matching cases are positive `if`s
   around the SendEvent; the PAINT case keeps the view pointer in a variable.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PsTrackSwitchProc */

#define EVT_SW_IN                     0x1c00007L
#define EVT_PAINT                     0x1c0000bL
#define EVT_REPAINT                   0x1c0000cL
#define EVT_SELE_DRAW                 0x1c0000eL
#define EVT_PARA_DRAW                 0x1c0000fL
#define EVT_TRSW_PART                 0x1c0002dL
#define EVT_TRSW_COMMAND              0x1c0002eL
#define EVT_CHECK_EDIT_SW             0x1e00053L
#define EVT_REQUEST_TRACK_SWITCH      0x1e00092L
#define EVT_TOGGLE_TRACK_SWITCH       0x1e00093L
#define NAKA_MAINFUNC_MainTrSwControl 0x140000aL

struct trswinst { unsigned char pad[22]; unsigned int part; };

extern long PsTrackSwitchProc(long, long, long);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern long MainFuncCall(long, long, long);

long AcTrackSwitchProc(long obj, long evt, long p)
{
	struct trswinst *v;

	switch (evt) {
	default:
		return PsTrackSwitchProc(obj, evt, p);
	case EVT_PAINT:
	case EVT_REPAINT:
		PsTrackSwitchProc(obj, evt, p);
		v = GetViewInstance(obj);
		MainFuncCall(NAKA_MAINFUNC_MainTrSwControl, EVT_REQUEST_TRACK_SWITCH, (long)v->part);
		break;
	case EVT_SW_IN:
		if (SendEvent(obj, EVT_CHECK_EDIT_SW, p)) {
			v = GetViewInstance(obj);
			MainFuncCall(NAKA_MAINFUNC_MainTrSwControl, EVT_TOGGLE_TRACK_SWITCH, (long)v->part);
			break;
		}
		return PsTrackSwitchProc(obj, evt, p);
	case EVT_TRSW_PART:
		PsTrackSwitchProc(obj, evt, p);
		v = GetViewInstance(obj);
		if ((unsigned int)(((unsigned long)p >> 16) & 0xfff) == v->part)
			SendEvent(obj, EVT_PARA_DRAW,
				((unsigned long)(((unsigned int)p >> 8) & 0xff) << 16) + (unsigned int)(p & 0xff));
		break;
	case EVT_TRSW_COMMAND:
		PsTrackSwitchProc(obj, evt, p);
		v = GetViewInstance(obj);
		if ((unsigned int)(((unsigned long)p >> 16) & 0xfff) == v->part)
			SendEvent(obj, EVT_SELE_DRAW, (int)(p & 0xffff));
		break;
	}
	return 0;
}
