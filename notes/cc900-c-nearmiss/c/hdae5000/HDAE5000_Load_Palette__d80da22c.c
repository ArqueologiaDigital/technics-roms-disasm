/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r54_misc_pal.c (2026-11-18-20-hd-r55)
   sha256 d80da22c458cd79f87f34f6cc67d3d2b76098c18a6d8840e392ee9010967af09 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: LoadPalette_c=HDAE5000_Load_Palette */
void HDAE5000_Palette_Setup(unsigned char index, unsigned char *rgb);
void LoadPalette_c(unsigned char (*pal)[4])
{
    int i;

    for (i = 255; i >= 0; i--)
        HDAE5000_Palette_Setup((unsigned char)i, pal[i]);
}
