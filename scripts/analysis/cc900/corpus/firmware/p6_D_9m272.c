/* Phase 6, lane_p6 helper D, round 9, module 272 (v10 ui/ui_widget_defs.s): TitleProc_ClearResourceDirtyFlag, which
   clears bits of TITLE_FLAGS and ends in a jump to MainFuncCall (same module).  Constants are the .equ values:
   NAKA_MAINFUNC_MainTitleControl 0x1400001, EVT_SET_TITLE_FLAG 0x1e000ba. */
/* cc900-module: MainFuncCall */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int TITLE_FLAGS;
extern long MainFuncCall(long, long, long);

long TitleProc_ClearResourceDirtyFlag(unsigned int m)
{
	TITLE_FLAGS &= ~m;
	return MainFuncCall(0x1400001L, 0x1e000baL, (unsigned long)TITLE_FLAGS);
}
