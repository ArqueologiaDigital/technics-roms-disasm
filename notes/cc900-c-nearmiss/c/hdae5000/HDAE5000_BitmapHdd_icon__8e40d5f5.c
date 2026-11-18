/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_small_procs.c (2026-11-18-26-hd-r56-ports)
   sha256 8e40d5f5afcc4103ca26ecc335d947e4cd9d326d5dbbd3b1d74513568e206137 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_BITMAP_DATA 0x1e000a1L
#define EVT_GET_BITMAP_WIDTH 0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
extern unsigned char HDAE5000_Bitmap_HddIcon[];
unsigned char *HDAE5000_BitmapHdd_icon(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return 0;
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_HddIcon;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x1b;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0x1b;
    }
}
