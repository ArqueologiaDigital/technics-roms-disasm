/* hd_r54_misc_bmp.c (helper h_misc, lane_hd round 54): four event procs that call nothing (each its own calr group;
   none calls another, so they share a file): HDAE5000_BitmapHdd_icon (hd-ae5000_v2_06i.s, 0x280395, 45 B),
   HDAE5000_BitmapButt01 (hdae5000_ui_display.s, 0x28b527, 45 B), HDAE5000_LanguageTextReturn (0x28f2f7, 17 B),
   HDAE5000_Alloc_Memory (0x28f543, 45 B; Boot_Init's calr target, it has no calr of its own).  No earlier probe
   defined any of them.
   cc900-options: -Xr
   cc900-name: LangTextReturn_b=HDAE5000_LanguageTextReturn

   The three bitmap descriptors have exactly the shape of the matched HDAE5000_Alloc_Memory_1/_2/_3
   (cc900/hdae5000_ttl_r1.c and siblings): `cp xbc` HEIGHT / WIDTH / DATA in place, the default (0) first, then
   DATA (lda xhl), WIDTH, HEIGHT; so the same switch with `default:` first.  BitmapHdd_icon is a real C proc
   (the firmware registers it by name, ObjHandler_Table entry 39), not data.
   LanguageTextReturn (ROM): `cp xbc,EVT_GET_LANGUAGE_PTR; jr nz; lda xhl,(table); ret; ld xhl,0; ret`.
     HDAE5000_LanguageTextReturn  an `if`
     LangTextReturn_b             a switch whose only case comes first (its compare inverted into the default)
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned char HDAE5000_Bitmap_HddIcon[];
extern unsigned char HDAE5000_Bitmap_Button01[];
extern unsigned char HDAE5000_Bitmap_BootSplash[];
extern char *HDAE5000_TextPtrs_LANENG001_to_LANENG006[];

/* XBC = EVT_GET_BITMAP_DATA / _WIDTH / _HEIGHT: the 27 x 27 HDD icon */
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

/* the 42 x 15 button bitmap */
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

/* EVT_GET_LANGUAGE_PTR: the module's language text table */
char **HDAE5000_LanguageTextReturn(long obj, long ev, long arg)
{
    if (ev == EVT_GET_LANGUAGE_PTR)
        return HDAE5000_TextPtrs_LANENG001_to_LANENG006;
    return 0;
}

char **LangTextReturn_b(long obj, long ev, long arg)
{
    switch (ev) {
    case EVT_GET_LANGUAGE_PTR:
        return HDAE5000_TextPtrs_LANENG001_to_LANENG006;
    default:
        return 0;
    }
}

/* the 320 x 240 boot splash */
unsigned char *HDAE5000_Alloc_Memory(long obj, long ev, long arg)
{
    switch (ev) {
    default:
        return 0;
    case EVT_GET_BITMAP_DATA:
        return HDAE5000_Bitmap_BootSplash;
    case EVT_GET_BITMAP_WIDTH:
        return (unsigned char *)0x140;
    case EVT_GET_BITMAP_HEIGHT:
        return (unsigned char *)0xf0;
    }
}
