/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m265b.c (2026-11-21-7-p6-r62)
   sha256 fb793d248cc34b46b453ca0cadb3e5a3d7e77014a9cb3c6421c7c4f697f57e4f (tar-sha256); compiled at -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_EXEC_PRESENTATION 0x1c10007L
void FDemo_LoadRegsAndPostEvent(void)
{
  long s = 0xea009eL;
  ApPostEvent(-1L, EVT_EXEC_PRESENTATION, s);
}
