/* lane_p6 helper N, round 6, form a: module 273 (ui/ui_widget_defs.s), retry of p6_N_5m273a (p6-r47 O3Xr: +35).
   ResetApTimer: the listing was the ROM's code with the test turned round; the ROM jumps to `return 0` when
   KillApTimer gives 0 and keeps the re-set inline: written with the set inside the `!= 0` branch.
   cc900-options: -O3 -Xr
*/
/* cc900-module: KillApTimer SetApTimer */

extern int KillApTimer(long time, long obj, long target, long event, long param);
extern int SetApTimer(long time, long obj, long target, long event, long param);

int ResetApTimer(long time, long obj, long target, long event, long param)
{
	if (KillApTimer(time, obj, target, event, param) != 0) {
		SetApTimer(time, obj, target, event, param);
		return 1;
	}
	return 0;
}
