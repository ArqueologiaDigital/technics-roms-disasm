/* Functions of hdae5000_ui_display.s.  (hdae5000_lyrics2.c, ported to hdae5000_v2_01i)
   Firmware C (cc900 phase 6), built by Toshiba V4.23.
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32 HDAE5000_Lyrics_FindEvent HDAE5000_Lyrics_ParseEvent
   cc900-module: HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_CheckHeaderChunk HDAE5000_Lyrics_CheckHdrChunk
   cc900-module: HDAE5000_Lyrics_CheckTrackChunk HDAE5000_Lyrics_ClearBuffer HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_ResetState
   v2.01i: the six text lines are 35 bytes long, not 40 (the row stride is 35, the local line buffer 35, so the
   frame is 4 bytes smaller), a line holds at most 34 characters, not 39, and the event data buffer is at
   0x230610, not 0x230636.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, char *, int);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);

/* the event HDAE5000_Lyrics_ParseEvent parsed last */
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
/* line state at 0x2304d8 */
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

extern char HDAE5000_RAM_LyricLines[6][35];
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
/* the line state as bytes too: its line lengths are reached as b[index + 16] (ROM: ld wa,(index); add wa,16;
   lda xbc,(0x2304d8); (xbc+wa)) */
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
extern unsigned char ram_230610[128];

extern char HDAE5000_Str_Empty_File_Delete[];
extern char HDAE5000_Str_Empty_File_Delete_2[];

long HDAE5000_Lyrics_FillLines(int, unsigned int);
long HDAE5000_Lyrics_FindEvent(int, int, int, long);

long HDAE5000_Lyrics_FillLines(int scroll, unsigned int pos)
{
    int slot;
    unsigned int cur;
    long r;
    unsigned long savetick;
    unsigned long savenext;
    char line[35];
    unsigned char first;
    unsigned int n;

    savetick = HDAE5000_RAM_LyricEvent.tick;
    savenext = HDAE5000_RAM_LyricEvent.nexttick;
    if ((unsigned char)scroll == 1) {
        for (slot = 0; slot < 5; slot++) {
            HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot],
                            (&HDAE5000_RAM_LyricLines[1])[slot]);
            LYR_LEN(slot) = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
        }
        first = 5;
    } else
        first = 0;
    cur = pos;
    for (slot = first; slot < 6; slot++) {
    top:
        line[0] = 0;
    next:
        r = HDAE5000_Lyrics_FindEvent(5, 2, -2, cur);
        if (HDAE5000_RAM_LyricEvent.eot == 1)
            goto tail;
        if (r <= 0)
            goto no_entry;
        if (ram_230610[0] != 0x0d)
            goto try_lf;
        cur = r;
        HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], line);
    store:
        LYR_LEN(slot) = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
    }
done:
    HDAE5000_RAM_LyricEvent.tick = savetick;
    HDAE5000_RAM_LyricEvent.nexttick = savenext;
    return cur;

try_lf:
    if (ram_230610[0] != 0x0a)
        goto other;
    cur = r;
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete);
    goto store;
other:
    if (HDAE5000_StrLen((char *)ram_230610) > 34) {
        cur = r;
        goto top;
    }
    n = HDAE5000_StrLen(line);
    if (HDAE5000_StrLen((char *)ram_230610) + n > 34)
        goto tail;
    HDAE5000_StrCat(line, (char *)ram_230610);
    cur = r;
no_entry:
    if (r == 0) {
        HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete_2);
        goto store;
    }
    if (r > 0)
        goto next;
tail:
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], line);
    LYR_LEN(slot) = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[slot]);
    if (HDAE5000_RAM_LyricEvent.eot != 1)
        goto store;
    HDAE5000_RAM_LyricEvent.eot = 0;
    goto done;
}
