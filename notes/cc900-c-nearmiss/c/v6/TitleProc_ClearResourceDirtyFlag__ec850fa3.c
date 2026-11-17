/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m272.c (2026-11-16-91-p6-r17)
   sha256 ec850fa30ae6f66cb92ad2bee25bcb9c8c05f873ebd54c1c99015d7adbec68d0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int TITLE_FLAGS;
extern long MainFuncCall(long, long, long);
long TitleProc_ClearResourceDirtyFlag(unsigned int m)
{
	TITLE_FLAGS &= ~m;
	return MainFuncCall(0x1400001L, 0x1e000baL, (unsigned long)TITLE_FLAGS);
}
