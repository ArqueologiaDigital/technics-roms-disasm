/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_window_procs_m0_xr.c (2026-11-16-68-p6-r12)
   sha256 1851b4bfe572ffd8e71ee2da787ed89fa42e0abf8cbbd9d06931c3309c204c5e (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
#define EVT_GET_BITMAP_DATA   0x1e000a1L
#define EVT_GET_BITMAP_WIDTH  0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
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
