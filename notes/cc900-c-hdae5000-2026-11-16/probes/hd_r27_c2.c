/* lane_hd round 27, helper h_r27c, file 2: functions of hdae5000_ui_display.s that sit in the C file of
   HDAE5000_Smf_SwapBytes16/32 and HDAE5000_Delay_Loop (hdae5000/cc900/hdae5000_ui_display.c: they call them with
   calr), in ROM address order: HDAE5000_VarInt_Encode, HDAE5000_VarInt_Decode, HDAE5000_Smf_ReadHeader,
   HDAE5000_Smf_CheckHeader, HDAE5000_VGA_Port_Write, HDAE5000_Palette_Setup.
   cc900-options: -Xr
   cc900-module: HDAE5000_Smf_SwapBytes32 HDAE5000_Smf_SwapBytes16 HDAE5000_Smf_CheckHeader
   cc900-module: HDAE5000_Delay_Loop HDAE5000_VGA_Port_Write
   cc900-name: VgaPortWrite_c=HDAE5000_VGA_Port_Write
   Reading of the hand source:
   - VarInt_Encode: value moves to XIX, n is HL (signed: `jr ge` / `jr lt`), i is IX; the 6-byte frame is the
     chunk buffer; `n - i - 1` and `n - 1` are finished in the index register (`ld de,wa; dec 1,de`).
   - VarInt_Decode: the first byte is kept in a byte register (IYL) and compared unsigned; the two ways to the
     `return -1` are one loop condition ((i <= 4 || first <= 7) && i <= 5).  `ld w,0; extz xwa` after `res 7,a`:
     the masked byte widened as an unsigned int (form b masks with a plain int constant).
   - Smf_ReadHeader: the media-type switch of the matched FdLyricList_Scan (cases 2, 3).
   - Smf_CheckHeader: format / tracks / division are stored, then format and division are read back from RAM
     (`cpw (sym),1`, `ld wa,(sym); bit 15,wa`): separate statements.
   - VGA_Port_Write takes the byte in C and stores it to the frame (a char parameter live across the call), while
     Palette_Setup loads BC with the widened byte (`extz wa; ld bc,wa`): the callers see an int prototype and the
     definition has the char parameter under its own C name, as the staged SongScrRefresh_c.
   - Palette_Setup: `(v >> 4) + 1` in byte width (`srl a,4; inc 1,a; extz wa`).
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

long HDAE5000_VarInt_Encode(unsigned long value, unsigned char *out)
{
    unsigned char tmp[6];
    int n;
    int i;

    n = 0;
    do {
        tmp[n] = value & 0x7f;
        value >>= 7;
        n++;
    } while (value != 0);
    for (i = 1; i < n; i++)
        out[n - i - 1] = tmp[i] | 0x80;
    out[n - 1] = tmp[0];
    return n;
}

long HDAE5000_VarInt_Decode(unsigned char *p, unsigned char *count)
{
    int i;
    long r;
    unsigned char first;

    i = 0;
    r = 0;
    first = p[0];
    do {
        r += p[i] & 0x7fU;
        if ((p[i] & 0x80) == 0) {
            *count = i + 1;
            return r;
        }
        i++;
        r <<= 7;
    } while ((i <= 4 || first <= 7) && i <= 5);
    return -1;
}

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

void VgaPortWrite_c(unsigned int port, unsigned char v)
{
    HDAE5000_Delay_Loop(0x100);
    *(unsigned char *)((unsigned long)port + IO_VGA_PORTS) = v;
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
