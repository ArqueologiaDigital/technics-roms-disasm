/* Functions of hdae5000_ui_display.s.  (hdae5000_lyrics_play.c)
   Firmware C (cc900 phase 6), built by Toshiba V4.23; promoted from cc900-staged/hdae5000_lyrics_play.c (checked in
   notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv).
   cc900-options: -Xr
   cc900-name: Lyr_PlayToPos_l=HDAE5000_Lyrics_PlayToPosition
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32 HDAE5000_Lyrics_FindEvent HDAE5000_Lyrics_ParseEvent
   cc900-module: HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_CheckHeaderChunk HDAE5000_Lyrics_CheckHdrChunk
   cc900-module: HDAE5000_Lyrics_CheckTrackChunk HDAE5000_Lyrics_ClearBuffer HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_ResetState
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct Point { int x, y; };
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
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };
struct LenCount { int len; unsigned int n; };

extern long HDAE5000_RAM_LyricBoxObj;
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
/* the line state as bytes too: its line lengths are reached as b[index + 16] */
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
extern struct Point ram_23087a;
extern char ram_23051e[];
extern unsigned char ram_230636[128];
extern char ram_2306b6[128];
extern char ram_230790[10];
extern unsigned char ram_2307a4, ram_2307a8;
extern unsigned int ram_2307ae, ram_2307b6;
extern int ram_2307b8[40];
extern unsigned char ram_230808[6];
extern int ram_23080e[39];
extern unsigned long ram_230864;
extern unsigned long ram_230868;
extern unsigned int ram_23086c, ram_230870;
extern unsigned char ram_230882;

extern char HDAE5000_Fmt_Fault_No_Lyrics_loaded_o[];
extern char HDAE5000_Fmt_i_i[], HDAE5000_Fmt_Chord_s[];

long HDAE5000_Lyrics_FillLines(int, unsigned int);
long HDAE5000_Lyrics_FindEvent(int, int, int, long);
unsigned int HDAE5000_Lyrics_ParseEvent(int, unsigned int);

/* the song position moved (pe->pos, in units of ram_230868 ticks): play the lyric track's events up to it;
   a syllable (meta 5) is placed on the current line, CR / LF and a full line move to the next line (the window
   scrolls from the third), meta 88 is the time signature, meta 126 with '0' a chord name */

/* len and n in a local structure */

/* len and n in a local array */

/* a second plain local holds StrLen's result */
void Lyr_PlayToPos_l(struct LyricPosEvt *pe, unsigned char redraw)
{
    long r;
    unsigned long t;
    int len;
    unsigned int n;
    int l;

    t = pe->pos * ram_230868;
    if (ram_230864 == t)
        return;
    ram_230864 = t;
    if (HDAE5000_RAM_LyricEvent.nexttick > ram_230864)
        return;
    if (HDAE5000_RAM_LyricEvent.eot != 0)
        return;
    n = 0;
    do {
        r = HDAE5000_Lyrics_FindEvent(0x7c, 2, -2, ram_23086c);
        if (HDAE5000_RAM_LyricEvent.eot == 1)
            return;
        if (r <= 0)
            goto fault;
        ram_23086c += r;
        n++;
        switch (HDAE5000_RAM_LyricEvent.type) {
        case 5:
            if (ram_230636[0] == 0x0d || ram_230636[0] == 0x0a) {
                ram_2304d8.s.col = 0;
                if (ram_2304d8.s.line >= 2)
                    goto scroll;
                ram_2304d8.s.line++;
                return;
            fault:
                HDAE5000_SPrintf((void *)ram_2306b6, HDAE5000_Fmt_Fault_No_Lyrics_loaded_o, r, ram_2307b6, n);
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 2L);
                return;
            scroll:
                r = HDAE5000_Lyrics_FillLines(1, ram_230870);
                ram_2304d8.s.hilite = 0;
                if (r > 0)
                    ram_230870 = r;
                if (redraw == 1)
                    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                return;
            }
            l = HDAE5000_StrLen((char *)ram_230636);
            len = l;
            if (l > 39)
                return;
            HDAE5000_StrCpy((void *)ram_23051e, (char *)ram_230636);
            if (len + ram_2304d8.s.col > 39) {
                ram_2304d8.s.col = 0;
                if (ram_2304d8.s.line < 2)
                    ram_2304d8.s.line++;
                else {
                    r = HDAE5000_Lyrics_FillLines(1, ram_230870);
                    if (r > 0)
                        ram_230870 = r;
                    if (redraw == 1)
                        CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                }
            }
            ram_23087a.x = ram_2307b8[LYR_LEN((int)ram_2304d8.s.line)] + ram_23080e[ram_2304d8.s.col];
            ram_23087a.y = ram_230808[ram_2304d8.s.line];
            ram_2304d8.s.col += len;
            ram_2304d8.s.hilite = 1;
            if (redraw == 1)
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 0L);
            if (ram_2304d8.s.col == ram_230870) {
                if (ram_230882 != 0x0d || ram_230882 != 0x0a) {
                    ram_2304d8.s.col = 0;
                    if (ram_2304d8.s.line < 2)
                        ram_2304d8.s.line++;
                    else {
                        r = HDAE5000_Lyrics_FillLines(1, ram_230870);
                        if (r > 0)
                            ram_230870 = r;
                        if (redraw == 1)
                            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                    }
                }
            }
            break;
        case 88:
            ram_2307a4 = ram_230636[0];
            if (ram_230636[1] == 1) {
                ram_2307a8 = 2;
                ram_2307ae = 24;
            }
            if (ram_230636[1] == 2) {
                ram_2307a8 = 4;
                ram_2307ae = 12;
            }
            if (ram_230636[1] == 3) {
                ram_2307a8 = 8;
                ram_2307ae = 6;
            }
            if (ram_230636[1] == 4) {
                ram_2307a8 = 16;
                ram_2307ae = 3;
            }
            HDAE5000_SPrintf((void *)ram_230790, HDAE5000_Fmt_i_i, ram_2307a4, ram_2307a8);
            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 4L);
            break;
        case 126:
            switch (ram_230636[0]) {
            case '0':
                HDAE5000_SPrintf((void *)ram_2306b6, HDAE5000_Fmt_Chord_s, &ram_230636[1]);
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 2L);
            }
            break;
        }
    } while (HDAE5000_RAM_LyricEvent.nexttick <= ram_230864 && r > 0);
}

/* control: two statements */
