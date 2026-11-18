/* Functions of hdae5000_ui_display.s.  (hdae5000_load_palette.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_load_palette.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-module: HDAE5000_Palette_Setup
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

void HDAE5000_Palette_Setup(unsigned char index, unsigned char *rgb);

void HDAE5000_Load_Palette(unsigned char (*pal)[4])
{
    int i;

    for (i = 255; i >= 0; i--)
        HDAE5000_Palette_Setup(i, pal[i]);
}
