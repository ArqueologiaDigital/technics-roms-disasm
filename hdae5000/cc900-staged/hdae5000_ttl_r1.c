/* TtlScreenRProc and its Alloc_Memory_1 (hd-ae5000_v2_06i.s): helper h_r27a's C that matches (module-local calls in cc900-module).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r27_a1.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_Alloc_Memory_1
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);

extern unsigned char HDAE5000_Bitmap_TitleLogo[];
extern unsigned char HDAE5000_Palette_TitleLogo[];

/* XBC = EVT_GET_BITMAP_DATA / _WIDTH / _HEIGHT: the bitmap, 320, 240; 0 for anything else.
   The ROM compares XBC in place (HEIGHT, WIDTH, DATA) and has the default's body first. */
unsigned char *HDAE5000_Alloc_Memory_1(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return 0;
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_TitleLogo;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x140;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0xf0;
    }
}

long HDAE5000_TtlScreenRProc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_DRAW:
        if (HDAE5000_Alloc_Memory_1(0L, EVT_GET_BITMAP_DATA, 0L) != 0) {
            HDAE5000_MemCopy((void *)0x56800L, (void *)HDAE5000_Bitmap_TitleLogo, 0x9600);
            HDAE5000_MemCopy((void *)0x5fe00L, (void *)(HDAE5000_Bitmap_TitleLogo + 0x9600), 0x9600);
            HDAE5000_MemCopy((void *)0x69400L, (void *)HDAE5000_Palette_TitleLogo, 0x400);
            CALLV(HAMA->ChangeWall)(3);
            CALLV(HAMA->ChangePalette)(3);
        }
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        return 0;
    case EVT_HIDE:
        CALLV(HAMA->ChangePalette)(2);
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}
