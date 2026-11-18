/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_small_procs.c (2026-11-18-26-hd-r56-ports)
   sha256 075f285aecce6167c9020bab2e52af889fa332d59a6817e0d7f4fb2f3a22af74 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_BITMAP_DATA 0x1e000a1L
#define EVT_GET_BITMAP_WIDTH 0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
extern unsigned char HDAE5000_Bitmap_Button01[];
unsigned char *HDAE5000_BitmapButt01(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return 0;
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_Button01;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x2a;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0x0f;
    }
}
