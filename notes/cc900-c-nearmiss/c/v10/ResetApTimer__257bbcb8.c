/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m273a.c (2026-11-19-37-p6-r47)
   sha256 257bbcb8109c1916401cca18dd5bc529e13f59f5db32518bee266c3bf4f4d6d8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern int KillApTimer(long time, long obj, long target, long event, long param);
extern int SetApTimer(long time, long obj, long target, long event, long param);
int ResetApTimer(long time, long obj, long target, long event, long param)
{
	if (KillApTimer(time, obj, target, event, param) == 0)
		return 0;
	SetApTimer(time, obj, target, event, param);
	return 1;
}
