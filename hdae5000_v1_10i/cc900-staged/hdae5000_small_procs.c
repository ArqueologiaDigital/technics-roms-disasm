/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_small_procs.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_small_procs.c.
   cc900-options: -Xr
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

/* EVT_GET_LANGUAGE_PTR: the module's language text table */
char **HDAE5000_LanguageTextReturn(long obj, long ev, long arg)
{
    if (ev == EVT_GET_LANGUAGE_PTR)
        return HDAE5000_TextPtrs_LANENG001_to_LANENG006;
    return 0;
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
