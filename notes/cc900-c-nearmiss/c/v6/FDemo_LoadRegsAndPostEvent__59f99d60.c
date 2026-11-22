/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc_m0.c (2026-11-21-10-p6-r65)
   sha256 59f99d6021a27ed7f269672d3dc7ad50375b38ca3f8d8760e4c5747f021b8cff (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern long ApPostEvent(long, long, long);
#define EVT_EXEC_PRESENTATION 0x1c10007L
#define STR_FEATURE 0xea009eL
void FDemo_LoadRegsAndPostEvent(void)
{
  ApPostEvent(-1L, EVT_EXEC_PRESENTATION, STR_FEATURE);
}
