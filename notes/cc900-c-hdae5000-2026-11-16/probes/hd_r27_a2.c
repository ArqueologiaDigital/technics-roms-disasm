/* hd_r27_a2.c (helper h_r27a): the drive-mechanism wallpaper class procedures and their bitmap descriptor,
   hd-ae5000_v2_06i.s.  Calr group: HDAE5000_Alloc_Memory_2 HDAE5000_TtlScreenR2Proc HDAE5000_IvScreenR2Proc.
   cc900-options: -Xr
   cc900-module: HDAE5000_Alloc_Memory_2
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);

extern unsigned char HDAE5000_Bitmap_DriveMech[];
extern unsigned char HDAE5000_Palette_DriveMech[];

unsigned char *HDAE5000_Alloc_Memory_2(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return 0;
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_DriveMech;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x140;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0xf0;
    }
}

long HDAE5000_TtlScreenR2Proc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_DRAW:
        if (HDAE5000_Alloc_Memory_2(0L, EVT_GET_BITMAP_DATA, 0L) != 0) {
            HDAE5000_MemCopy((void *)0x56800L, (void *)HDAE5000_Bitmap_DriveMech, 0x9600);
            HDAE5000_MemCopy((void *)0x5fe00L, (void *)(HDAE5000_Bitmap_DriveMech + 0x9600), 0x9600);
            HDAE5000_MemCopy((void *)0x69400L, (void *)HDAE5000_Palette_DriveMech, 0x400);
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

/* the same without the bitmap copies: only the palette */
long HDAE5000_IvScreenR2Proc(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_DRAW:
        if (HDAE5000_Alloc_Memory_2(0L, EVT_GET_BITMAP_DATA, 0L) != 0) {
            HDAE5000_MemCopy((void *)0x69400L, (void *)HDAE5000_Palette_DriveMech, 0x400);
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
