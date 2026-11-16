/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_1b.c (2026-11-16-45-p6-r9)
   sha256 458fac3c50a56452c643aff2a328f80b03d0e17483a3bfc68b066764994c47b5 (tar-sha256); compiled at -O3 -Xr */
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
	default:
		return 0;
	}
}
