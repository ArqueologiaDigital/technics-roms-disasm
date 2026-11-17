/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_xr.c (2026-11-16-55-p6-r10)
   sha256 763b1adf71c59dbe912867e130b3587fe75f37d9924903bb2908e64929d9cafe (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
#define EVT_GET_BITMAP_DATA 0x1e000a1L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
#define EVT_GET_BITMAP_WIDTH 0x1e000a2L
extern unsigned char UserBitmapCheck_Bitmap24x24[];
long UserBitmapCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_BITMAP_DATA:
		return (long)UserBitmapCheck_Bitmap24x24;
	case EVT_GET_BITMAP_WIDTH:
	case EVT_GET_BITMAP_HEIGHT:
		return 24;
	}
	return 0;
}
