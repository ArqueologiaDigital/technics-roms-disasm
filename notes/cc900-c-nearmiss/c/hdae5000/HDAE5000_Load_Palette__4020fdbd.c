/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_load_palette.c (2026-11-18-24-hd-r56)
   sha256 4020fdbd96f1b22404690060903c515fc4022cc4d79160abbf84dd4aeda21414 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
void HDAE5000_Palette_Setup(unsigned char index, unsigned char *rgb);
void HDAE5000_Load_Palette(unsigned char (*pal)[4])
{
    int i;

    for (i = 255; i >= 0; i--)
        HDAE5000_Palette_Setup(i, pal[i]);
}
