/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m265a.c (2026-11-21-2-p6-r58)
   sha256 40059c89b2cbbf9f54cced054d207a54032edb8e6b525704e5e8d8e85d9256d4 (tar-sha256); compiled at -O3 -XS -Xr */
extern char FDemo_LoadRegsAndPostEvent_Str_FEATURE[];
extern long ApPostEvent(long, long, long);
#define EVT_EXEC_PRESENTATION 0x1c10007L
void FDemo_LoadRegsAndPostEvent(void)
{
  ApPostEvent(-1L, EVT_EXEC_PRESENTATION, (long)FDemo_LoadRegsAndPostEvent_Str_FEATURE);
}
