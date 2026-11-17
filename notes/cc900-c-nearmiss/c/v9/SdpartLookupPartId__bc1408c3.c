/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawbar_panel_ui_xr.c (2026-11-16-55-p6-r10)
   sha256 bc1408c33007781ce6126a2d095a73f654f0bd56267c7202ba40f66b5268fe07 (tar-sha256); compiled at -O3 -Xr
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
