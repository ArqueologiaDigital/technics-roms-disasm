/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_smf_palette.c (2026-11-16-117-hd-r29-staged)
   sha256 b806c21e3e4f83bcda59d9858d5a7f2aff0b7d6a2a3d0750a80c35f65328a33f (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
extern void HDAE5000_VGA_Port_Write(unsigned int port, int v);
void HDAE5000_Palette_Setup(unsigned char index, unsigned char *rgb)
{
    HDAE5000_VGA_Port_Write(0x3c8, index);
    if (rgb[0] & 0x08) {
        if (rgb[0] < 0xf0)
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)((rgb[0] >> 4) + 1));
        else
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[0] >> 4));
    } else
        HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[0] >> 4));
    if (rgb[1] & 0x08) {
        if (rgb[1] < 0xf0)
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)((rgb[1] >> 4) + 1));
        else
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[1] >> 4));
    } else
        HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[1] >> 4));
    if (rgb[2] & 0x08) {
        if (rgb[2] < 0xf0)
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)((rgb[2] >> 4) + 1));
        else
            HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[2] >> 4));
    } else
        HDAE5000_VGA_Port_Write(0x3c9, (unsigned char)(rgb[2] >> 4));
}
