/* hd_r54_misc_pal.c (helper h_misc, lane_hd round 54): HDAE5000_Load_Palette (hdae5000_ui_display.s, 0x28f8e0,
   43 B, survey C-calr), whose calr target HDAE5000_Palette_Setup is matched C (cc900/hdae5000_smf_palette.c,
   declared here with that file's prototype).  No earlier probe defined Load_Palette (hd_r20_uic.c only called it).
   cc900-options: -Xr
   cc900-module: HDAE5000_Palette_Setup
   cc900-name: LoadPalette_b=HDAE5000_Load_Palette
   cc900-name: LoadPalette_c=HDAE5000_Load_Palette
   cc900-name: LoadPalette_d=HDAE5000_Load_Palette

   ROM: a 4-byte frame for pal (`dec 4,xsp; pushw iz; ld (xsp+2),xwa`), i in IZ from 255 down to 0 (entry test
   `cp iz,0; jr lt`, signed), per entry `ld e,izl` FIRST (the index argument converted int -> unsigned char,
   evaluated early), then `ld wa,iz; exts xwa; sll xwa,2; ld xbc,xwa; add xbc,(xsp+2)` (pal + i scaled by 4 AFTER
   the extension: a 4-byte element type, passed with no conversion so loaded late), `ld a,e`, calr; bottom
   `sub iz,1; jr ge` (no `cp iz,0`: the flags of the sub).  `ld e,izl` is `ldto_berp E,0xF8` in the hand source.
     HDAE5000_Load_Palette  pal an `unsigned char (*)[4]`, `pal[i]` decays to the `unsigned char *` parameter; i--
     LoadPalette_b          the same with `i -= 1` (the ROM's `sub iz,1` rather than `dec 1,iz`)
     LoadPalette_c          the same with an explicit `(unsigned char)i`
     LoadPalette_d          pal an `unsigned char *`, the entry `pal + (long)i * 4`
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

void LoadPalette_b(unsigned char (*pal)[4])
{
    int i;

    for (i = 255; i >= 0; i -= 1)
        HDAE5000_Palette_Setup(i, pal[i]);
}

void LoadPalette_c(unsigned char (*pal)[4])
{
    int i;

    for (i = 255; i >= 0; i--)
        HDAE5000_Palette_Setup((unsigned char)i, pal[i]);
}

void LoadPalette_d(unsigned char *pal)
{
    int i;

    for (i = 255; i >= 0; i--)
        HDAE5000_Palette_Setup(i, pal + (long)i * 4);
}
