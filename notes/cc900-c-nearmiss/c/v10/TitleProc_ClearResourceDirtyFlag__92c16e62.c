/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_9m272.c (2026-11-16-87-p6-r15)
   sha256 92c16e626882041798b5a620733486584d57b9bf56d6db5956c4f41baaaf3339 (tar-sha256); compiled at -Xr */
extern unsigned int TITLE_FLAGS;
extern long MainFuncCall(long, long, long);
long TitleProc_ClearResourceDirtyFlag(unsigned int m)
{
	TITLE_FLAGS &= ~m;
	return MainFuncCall(0x1400001L, 0x1e000baL, (unsigned long)TITLE_FLAGS);
}
