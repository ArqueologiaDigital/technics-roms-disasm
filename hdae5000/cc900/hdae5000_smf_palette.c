/* Functions of hdae5000_ui_display.s.  (hdae5000_smf_palette.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_smf_palette.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
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

long HDAE5000_Smf_ReadHeader(char *name)
{
    switch (CALLR(unsigned char, HAMA->GetMediaType)()) {
    case 2:
    case 3:
        CALLV(ROOT->SleepMainTask)();
        CALLV(HAMA->fopen_ext)(name, HDAE5000_Str_Rb_Smf_ReadHeader);
        CALLV(HAMA->fread_ext)(&HDAE5000_RAM_SmfHeader, 14L);
        CALLV(HAMA->fclose_ext)();
        CALLV(ROOT->WakeUpMainTask)();
    }
    return HDAE5000_Smf_CheckHeader(&HDAE5000_RAM_SmfHeader);
}

long HDAE5000_Smf_CheckHeader(struct SmfHdr *h)
{
    if (HDAE5000_Smf_SwapBytes32(h->magic) != 0x4d546864L)
        return -1;
    if (HDAE5000_Smf_SwapBytes32(h->len) != 6)
        return -2;
    HDAE5000_RAM_SmfFormat = HDAE5000_Smf_SwapBytes16(h->format);
    if (HDAE5000_RAM_SmfFormat > 1)
        return -3;
    HDAE5000_RAM_SmfTrackCount = HDAE5000_Smf_SwapBytes16(h->tracks);
    HDAE5000_RAM_SmfDivision = HDAE5000_Smf_SwapBytes16(h->division);
    if (HDAE5000_RAM_SmfDivision & 0x8000)
        return -4;
    return 0;
}

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
