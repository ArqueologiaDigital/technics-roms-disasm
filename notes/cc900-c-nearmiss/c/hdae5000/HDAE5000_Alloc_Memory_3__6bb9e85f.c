/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_ttl_r3.c (2026-11-16-116-hd-r27c)
   sha256 6bb9e85fd2499b5cfc7666e34ac23e93e96f668a840ef3acd74e111d3a824034 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_BITMAP_DATA 0x1e000a1L
#define EVT_GET_BITMAP_WIDTH 0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
extern unsigned char HDAE5000_Bitmap_FilePanel[];
unsigned char *HDAE5000_Alloc_Memory_3(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return 0;
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_FilePanel;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x140;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0xf0;
    }
}
