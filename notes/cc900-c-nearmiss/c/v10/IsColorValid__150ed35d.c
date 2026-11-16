/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m273_xr.c (2026-11-16-68-p6-r12)
   sha256 150ed35dd464c71c836eddda1367119362919420b9c7e122a91be0c63994c6a4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
int IsColorValid(int c)
{
	if ((c >= 0 && c <= 0xff) || (c >= 0x100 && c <= 0x100)) return 1;
	return 0;
}
