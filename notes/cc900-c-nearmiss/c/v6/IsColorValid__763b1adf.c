/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_xr.c (2026-11-16-55-p6-r10)
   sha256 763b1adf71c59dbe912867e130b3587fe75f37d9924903bb2908e64929d9cafe (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
int IsColorValid(int c)
{
	if ((c >= 0 && c <= 0xff) || (c >= 0x100 && c <= 0x100)) return 1;
	return 0;
}
