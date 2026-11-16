/* hdae5000_v1_10i: the functions of hdae5000/cc900-staged/hdae5000_smf_palette.c that V4.23 reproduces unchanged in HD-AE5000 v1.10i (port_staged.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_smf_palette.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_Smf_SwapBytes32 HDAE5000_Smf_SwapBytes16 HDAE5000_Smf_CheckHeader
   cc900-module: HDAE5000_Delay_Loop HDAE5000_VGA_Port_Write
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct SmfHdr { unsigned long magic; unsigned long len; unsigned int format; unsigned int tracks;
                unsigned int division; };

/* ---- this file (calr) ---- */
extern unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x);
extern unsigned int HDAE5000_Smf_SwapBytes16(unsigned int x);
extern void HDAE5000_Delay_Loop(unsigned long n);
long HDAE5000_Smf_CheckHeader(struct SmfHdr *h);
extern void HDAE5000_VGA_Port_Write(unsigned int port, int v);   /* the callers' view: BC */
void VgaPortWrite_c(unsigned int port, unsigned char v);

/* ---- RAM / ROM ---- */
extern struct SmfHdr HDAE5000_RAM_SmfHeader;
extern unsigned int HDAE5000_RAM_SmfFormat;
extern unsigned int HDAE5000_RAM_SmfTrackCount;
extern unsigned int HDAE5000_RAM_SmfDivision;
extern char HDAE5000_Str_Rb_Smf_ReadHeader[];

#define IO_VGA_PORTS 0x170000L    /* HDAE5000_IO_VgaPorts */

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
