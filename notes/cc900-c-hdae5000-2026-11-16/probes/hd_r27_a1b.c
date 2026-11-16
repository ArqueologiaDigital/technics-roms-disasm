/* hd_r27_a1b.c (helper h_r27a): second form of hd_r27_a1.c.  Alloc_Memory_1 with the default written last;
   TtlScreenRProc with the copies' sources as unsigned char * (converted by the
   const void * parameter only) and &arr[0x9600].
   cc900-options: -Xr
   cc900-module: HDAE5000_Alloc_Memory_1
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);

extern unsigned char HDAE5000_Bitmap_TitleLogo[];
extern unsigned char HDAE5000_Palette_TitleLogo[];

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

long HDAE5000_TtlScreenRProc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_DRAW:
        if (HDAE5000_Alloc_Memory_1(0L, EVT_GET_BITMAP_DATA, 0L)) {
            HDAE5000_MemCopy((unsigned char *)0x56800L, HDAE5000_Bitmap_TitleLogo, 0x9600);
            HDAE5000_MemCopy((unsigned char *)0x5fe00L, &HDAE5000_Bitmap_TitleLogo[0x9600], 0x9600);
            HDAE5000_MemCopy((unsigned char *)0x69400L, HDAE5000_Palette_TitleLogo, 0x400);
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
