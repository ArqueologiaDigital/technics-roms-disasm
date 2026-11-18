/* Functions of hd-ae5000_v2_06i.s.  (hdae5000_small_procs.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_small_procs.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
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

/* the 320 x 240 boot splash */
