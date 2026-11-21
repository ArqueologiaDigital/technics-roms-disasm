/* Functions of hdae5000_ui_display.s.  (hdae5000_lyrics.c, v2.01i)
   Firmware C (cc900 phase 6) for HD-AE5000 v2.01i, round 87 (2026-11-20).
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32 HDAE5000_Lyrics_FindEvent HDAE5000_Lyrics_ParseEvent
   cc900-module: HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_CheckHeaderChunk HDAE5000_Lyrics_CheckHdrChunk
   cc900-module: HDAE5000_Lyrics_CheckTrackChunk HDAE5000_Lyrics_ClearBuffer HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_ResetState
   v2.01i's lyric RAM below the line state sits lower than v2.06i's, by varying amounts, and two text buffers are
   smaller: the copyright text holds 35 characters (limit 36, v2.06i 50) and the song title 22 (limit 23, v2.06i
   40).  The cells, read from v2.01i's hand source (v2.06i address in brackets): event text 0x230610 [0x230636],
   copyright 0x230710 [0x230736], title 0x230734 [0x230768], beat message 0x23074c [0x230790], beat numerator /
   copy / denominator bytes 0x230760 / 0x230762 / 0x230764 [0x2307a4 / a6 / a8], tick steps 0x23076a / 0x23076c
   [0x2307ae / b0], 0x230816 [0x23086e], the var-length count 0x230806 [0x23085e].  Otherwise v2.06i's C.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, char *, int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct LyricEvent {
    int type;                   /* +0  meta type, 0x2f = end of track */
    int w2;
    int eot;                    /* +4  end of track reached */
    unsigned int len;           /* +6  data length */
    unsigned int pos;           /* +8  position of the event */
    unsigned int endpos;        /* +10 position after it */
    unsigned int prevpos;       /* +12 */
    int w14;
    unsigned long tick;         /* +16 running tick */
    unsigned long nexttick;     /* +20 tick of the next event */
    unsigned long l24, l28, l32, l36;
    unsigned char data[128];    /* +40 */
};
struct LyrLine {
    long l0;
    char p4[4];
    int w8, w10;
    unsigned int col;           /* +12 column of the next syllable */
    int w14;
    unsigned char len[6];       /* +16 length of each text line */
    unsigned char line;         /* +22 current line */
    unsigned char b23;
    unsigned char hilite;       /* +24 */
};
union LyrLineU { unsigned char b[25]; struct LyrLine s; };

extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern long HDAE5000_RAM_LyricBoxObj;
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
extern union LyrLineU ram_2304d8;
extern unsigned char ram_230610[128];
extern char ram_230710[36];
extern char ram_230734[23];
extern char ram_23074c[10];
extern unsigned char ram_230760, ram_230762, ram_230764;
extern unsigned int ram_23076a, ram_23076c;
extern unsigned int ram_230806;
extern unsigned int ram_230816;
extern char HDAE5000_Str_NoCopyrightInfo[], HDAE5000_Str_NoSongTitle[], HDAE5000_Fmt_i_i_File_Load[];

#define LYRIC_EV(i) (&HDAE5000_RAM_LyricBuffer[22])[i]

long HDAE5000_Lyrics_FindEvent(int, int, int, long);

long HDAE5000_Lyrics_ReadVarLen(pos)
unsigned int pos;
{
    unsigned long v = 0;
    unsigned int i;
    for (i = 0; i < 4; i++) {
        v += LYRIC_EV(pos + i) & 0x7f;
        if (LYRIC_EV(pos + i) < 0x80) {
            ram_230806 = i + 1;
            return v;
        }
        v <<= 7;
    }
    return -1L;
}

long HDAE5000_Lyrics_ReadSongInfo(unused)
long unused;
{
    if (HDAE5000_Lyrics_FindEvent(2, 2, -2, 0L) > 0) {
        if (HDAE5000_RAM_LyricEvent.len >= 36) {
            HDAE5000_StrNCpy((void *)ram_230710, (char *)ram_230610, 36);
            ram_230710[35] = 0;
        } else {
            HDAE5000_StrNCpy((void *)ram_230710, (char *)ram_230610, HDAE5000_RAM_LyricEvent.len);
            ram_230710[HDAE5000_RAM_LyricEvent.len] = 0;
        }
    } else
        HDAE5000_StrCpy((void *)ram_230710, HDAE5000_Str_NoCopyrightInfo);
    if (HDAE5000_Lyrics_FindEvent(3, 2, -2, 0L) > 0) {
        if (HDAE5000_RAM_LyricEvent.len >= 23) {
            HDAE5000_StrNCpy((void *)ram_230734, (char *)ram_230610, 23);
            ram_230734[22] = 0;
        } else {
            HDAE5000_StrNCpy((void *)ram_230734, (char *)ram_230610, HDAE5000_RAM_LyricEvent.len);
            ram_230734[HDAE5000_RAM_LyricEvent.len] = 0;
        }
    } else
        HDAE5000_StrCpy((void *)ram_230710, HDAE5000_Str_NoSongTitle);
    if (HDAE5000_Lyrics_FindEvent(88, 2, -2, 0L) > 0) {
        ram_230762 = ram_230760 = ram_230610[0];
        if (ram_230610[1] == 1) {
            ram_230764 = 2;
            ram_23076a = 24;
            ram_23076c = 24;
        }
        if (ram_230610[1] == 2) {
            ram_230764 = 4;
            ram_23076a = 12;
            ram_23076c = 12;
        }
        if (ram_230610[1] == 3) {
            ram_230764 = 8;
            ram_23076a = 6;
            ram_23076c = 6;
        }
        if (ram_230610[1] == 4) {
            ram_230764 = 16;
            ram_23076a = 3;
            ram_23076c = 3;
        }
    } else {
        ram_230762 = 4;
        ram_230760 = 4;
        ram_230764 = 4;
        ram_23076a = 12;
        ram_23076c = 12;
    }
    HDAE5000_SPrintf((void *)ram_23074c, HDAE5000_Fmt_i_i_File_Load, ram_230760, ram_230764);
    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_BEAT_MESSAGE, 0L);
    HDAE5000_RAM_LyricEvent.type = 0xff;
    HDAE5000_RAM_LyricEvent.w2 = 0;
    HDAE5000_RAM_LyricEvent.eot = 0;
    HDAE5000_RAM_LyricEvent.len = 0;
    ram_2304d8.s.hilite = 0;
    ram_230816 = 0;
    HDAE5000_RAM_LyricEvent.tick = 0;
    HDAE5000_Lyrics_FindEvent(0x7c, 2, -2, 0L);
    HDAE5000_RAM_LyricEvent.tick = 0;
    return 0;
}
