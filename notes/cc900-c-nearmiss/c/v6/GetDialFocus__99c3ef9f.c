/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/presentation_sound_nav_xr.c (2026-11-16-55-p6-r10)
   sha256 99c3ef9f546105f36d17ee086d4608eb41121b725560dd1a29db0a34081e51bc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int DIAL_ENABLE;
extern long DIAL_FOCUS;
long GetDialFocus(void)
{
	if (DIAL_ENABLE == 0) return -1;
	return DIAL_FOCUS;
}
