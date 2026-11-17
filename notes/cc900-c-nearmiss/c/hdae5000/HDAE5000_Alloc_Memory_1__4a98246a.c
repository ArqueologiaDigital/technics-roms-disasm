/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_a1b.c (2026-11-16-113-hd-r27a)
   sha256 4a98246aff6259b66c70db52cb51a4f5ad1a3d3e039a59079410f689d3c6a8f7 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
#define EVT_GET_BITMAP_DATA 0x1e000a1L
#define EVT_GET_BITMAP_WIDTH 0x1e000a2L
#define EVT_GET_BITMAP_HEIGHT 0x1e000a3L
extern unsigned char HDAE5000_Bitmap_TitleLogo[];
unsigned char *HDAE5000_Alloc_Memory_1(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_TitleLogo;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x140;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0xf0;
    default:
        return 0;
    }
}
