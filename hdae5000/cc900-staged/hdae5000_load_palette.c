/* Load_Palette of hdae5000_ui_display.s
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r54_misc_pal.c.
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
