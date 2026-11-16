/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/drawbar_panel_ui_m264_xr.c (2026-11-16-68-p6-r12)
   sha256 07ffdbb0f0b6c615eed75d365812181c63b8d6e4aa8e524ff4ef8a277a0698a4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
int SdpartLookupPartId(unsigned int *p, unsigned int v)
{
	int n = 0;

	while (*p != 0xffff) {
		if (*p == v) break;
		p++;
		n++;
	}
	if (*p != 0xffff) return n;
	return -1;
}
