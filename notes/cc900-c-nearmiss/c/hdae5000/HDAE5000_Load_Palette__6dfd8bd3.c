/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_load_palette.c (2026-11-18-26-hd-r56-ports)
   sha256 6dfd8bd3f39404963641e751ffc392f230cab8d7633b410f1e7282116e0c25d3 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
void HDAE5000_Palette_Setup(unsigned char index, unsigned char *rgb);
void HDAE5000_Load_Palette(unsigned char (*pal)[4])
{
    int i;

    for (i = 255; i >= 0; i--)
        HDAE5000_Palette_Setup(i, pal[i]);
}
