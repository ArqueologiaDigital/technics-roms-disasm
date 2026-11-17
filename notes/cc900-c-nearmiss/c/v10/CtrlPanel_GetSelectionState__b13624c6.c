/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_2b.c (2026-11-16-35-p6-r3)
   sha256 b13624c69fcb835af433e38ef56581fa94d5aa79da286905b3f16a25d5e2a17d (tar-sha256); compiled at -Xr */
extern unsigned int TITLE_FLAGS_LATCHED;
int CtrlPanel_GetSelectionState(void)
{
	if (TITLE_FLAGS_LATCHED & 1) return 1;
	if ((TITLE_FLAGS_LATCHED & 2) && !(TITLE_FLAGS_LATCHED & 0x18)) return 2;
	return 0;
}
