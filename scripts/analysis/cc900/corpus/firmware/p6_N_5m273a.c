/* lane_p6 helper N, round 5, form a: module 273 (ui/ui_widget_defs.s), new function.
   ResetApTimer: kills the application timer {time, obj, target, event, param} (the built KillApTimer,
   cc900/ui_widget_defs_m273.c) and, when one was running, sets it again: 1, else 0.  Five long parameters, the
   last two on the stack (retd 8).
   cc900-options: -O3 -Xr
*/
/* cc900-module: KillApTimer SetApTimer */

extern int KillApTimer(long time, long obj, long target, long event, long param);
extern int SetApTimer(long time, long obj, long target, long event, long param);

int ResetApTimer(long time, long obj, long target, long event, long param)
{
	if (KillApTimer(time, obj, target, event, param) == 0)
		return 0;
	SetApTimer(time, obj, target, event, param);
	return 1;
}
