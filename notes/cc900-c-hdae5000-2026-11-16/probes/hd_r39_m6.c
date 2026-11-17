/* lane_hd round 39, helper h_m6: the lyric module's three unsolved functions, in ROM order (0x28d6d1 PlayToPosition,
   0x28de2c FillLines, 0x28e187 ParseEvent), each followed by its variants.  Prototype-style definitions only.
   cc900-options: -Xr
   cc900-module: HDAE5000_SwapBytes16 HDAE5000_SwapBytes32 HDAE5000_Lyrics_FindEvent HDAE5000_Lyrics_ParseEvent
   cc900-module: HDAE5000_Lyrics_ReadVarLen HDAE5000_Lyrics_CheckHeaderChunk HDAE5000_Lyrics_CheckHdrChunk
   cc900-module: HDAE5000_Lyrics_CheckTrackChunk HDAE5000_Lyrics_ClearBuffer HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_ResetState
   The bodies are hd_r13_lyra.c's (run 2026-11-16-75), whose V4.23 code was compared again with the hand source.
   What differed there, and the change here:
   - PlayToPosition: (1) the syllable length, ROM `ld (len),hl; cp hl,39; jrl gt`: every assignment used as an operand
     reloaded it (`ld wa,(len); cp wa,39`), so it is two statements, len = StrLen(..); if (len > 39) (V4.23 compares
     the register just assigned in the next statement: ParseEvent's `cp xhl,-1`).  (2) the line-length index, ROM
     `ld a,(line); extz wa; add wa,16`: V4.23 added in 8 bits (`add a,16; extz wa`) for the unsigned char index, so
     the index is widened first, LYR_LEN((unsigned int)line).  (3) the char parameter (ROM `ld (xsp+8),c`, then
     `cp (xsp+8),1`): see the variants.
   - FillLines: no difference found in run 75's code (its ERR-translate was the listing's cut operand field); only
     the char parameter changes (ROM `cp a,1`, the parameter never stored).
   - ParseEvent: the tick of the next event, ROM `ld xwa,(tick); add xwa,(l32)`: V4.23 loads the RIGHT operand of a
     sum of two memory operands first, so it is l32 + tick.  The char parameter (ROM `ld (xsp+4),bc; ld (xsp+6),a`,
     then `ld a,(xsp+6); and a,1`): see the variants.
   Variants (short C names, one cc900-name line each):
   - HDAE5000_Lyrics_PlayToPosition: int redraw, tested as (unsigned char)redraw == 1.
     Lyr_PlayToPos_v1: unsigned char redraw in the prototype (the callee's code of the old-style definition; its
     caller LyricBoxProc is in another file).  Lyr_PlayToPos_v2: as v1, with unsigned int len tested as (int)len > 39
     and the index widened with (int).  Lyr_PlayToPos_v3: int redraw copied to an unsigned char local (declared
     last) by the first statement; the length as an assignment operand through StrLen cast to a function returning
     int (no conversion in the assignment).
   - HDAE5000_Lyrics_FillLines: int scroll, tested as (unsigned char)scroll == 1.  Lyr_FillLines_v1: (char)scroll.
     Lyr_FillLines_v2: unsigned char scroll in the prototype (a control: its callers here load WA).
   - HDAE5000_Lyrics_ParseEvent: int flags, both parameters copied to locals declared last (ps, f) by the first two
     statements.  Lyr_ParseEvent_v1: int flags used through (unsigned char) casts, pos used directly.
     Lyr_ParseEvent_v2: unsigned char flags in the prototype (a control for the sum's order).
   The declarations are hdae5000/cc900/hdae5000_lyrics.c's. */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern char *__cdecl HDAE5000_StrNCpy(char *, char *, int);
extern char *__cdecl HDAE5000_StrCat(char *, char *);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern int __cdecl HDAE5000_MemCmp(const void *, const void *, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
/* the lyric box's view instance (RootFn_GetViewInstance) */
struct LyrView { char p0[22]; int a22; char p1[4]; int *flag; long l32; char p2[4]; long l40; int a44; };
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

extern unsigned char HDAE5000_RAM_LyricBuffer[0x5000];
extern char HDAE5000_RAM_LyricLines[6][40];
extern unsigned char HDAE5000_RAM_LyricLoaded;
extern long HDAE5000_RAM_LyricBoxObj;
extern unsigned long HDAE5000_RAM_LyricFileLength;
extern unsigned char HDAE5000_RAM_LyricForeColor;
extern unsigned char HDAE5000_RAM_LyricBackColor;
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
/* the line state as bytes too: its line lengths are reached as b[index + 16] (ROM: ld wa,(index); add wa,16;
   lda xbc,(0x2304d8); (xbc+wa)) */
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
extern struct Point ram_23087a;
extern char ram_23051e[];
extern unsigned char ram_230636[128];
extern char ram_2306b6[128];
extern char ram_230790[10];
extern unsigned char ram_2307a4, ram_2307a6, ram_2307a8;
extern unsigned int ram_2307aa, ram_2307ac, ram_2307ae, ram_2307b0, ram_2307b2, ram_2307b4, ram_2307b6;
extern int ram_2307b8[40];
extern unsigned char ram_230808[6];
extern int ram_23080e[39];
extern unsigned int ram_23085e;
extern long ram_230860;
extern unsigned long ram_230864;
extern unsigned long ram_230868;
extern unsigned int ram_23086c, ram_23086e, ram_230870, ram_230872, ram_230874;
extern unsigned char ram_23087e, ram_230880, ram_230882;

extern char HDAE5000_Fmt_Fault_No_Lyrics_loaded_o[];
extern char HDAE5000_Fmt_i_i[], HDAE5000_Fmt_Chord_s[];
extern char HDAE5000_Str_Empty_File_Delete[];
extern char HDAE5000_Str_Empty_File_Delete_2[];

/* events of the lyric track start at +22, after the TLhd (14) and TLtr (8) headers */
#define LYRIC_EV(i) (&HDAE5000_RAM_LyricBuffer[22])[i]

void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *, int);
long HDAE5000_Lyrics_FillLines(int, unsigned int);
long HDAE5000_Lyrics_FindEvent(int, int, int, long);
unsigned int HDAE5000_Lyrics_ParseEvent(int, unsigned int);
long HDAE5000_Lyrics_ReadVarLen(unsigned int);

void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *pe, int redraw)
{
    long r;
    unsigned long t;
    int len;
    unsigned int n;

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
                if ((unsigned char)redraw == 1)
                    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                return;
            }
            len = HDAE5000_StrLen((char *)ram_230636);
            if (len > 39)
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
                    if ((unsigned char)redraw == 1)
                        CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                }
            }
            ram_23087a.x = ram_2307b8[LYR_LEN((unsigned int)ram_2304d8.s.line)] + ram_23080e[ram_2304d8.s.col];
            ram_23087a.y = ram_230808[ram_2304d8.s.line];
            ram_2304d8.s.col += len;
            ram_2304d8.s.hilite = 1;
            if ((unsigned char)redraw == 1)
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
                        if ((unsigned char)redraw == 1)
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

/* cc900-name: Lyr_PlayToPos_v1=HDAE5000_Lyrics_PlayToPosition */
void Lyr_PlayToPos_v1(struct LyricPosEvt *pe, unsigned char redraw)
{
    long r;
    unsigned long t;
    int len;
    unsigned int n;

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
            len = HDAE5000_StrLen((char *)ram_230636);
            if (len > 39)
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
            ram_23087a.x = ram_2307b8[LYR_LEN((unsigned int)ram_2304d8.s.line)] + ram_23080e[ram_2304d8.s.col];
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

/* cc900-name: Lyr_PlayToPos_v2=HDAE5000_Lyrics_PlayToPosition */
void Lyr_PlayToPos_v2(struct LyricPosEvt *pe, unsigned char redraw)
{
    long r;
    unsigned long t;
    unsigned int len;
    unsigned int n;

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
            len = HDAE5000_StrLen((char *)ram_230636);
            if ((int)len > 39)
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

/* cc900-name: Lyr_PlayToPos_v3=HDAE5000_Lyrics_PlayToPosition */
void Lyr_PlayToPos_v3(struct LyricPosEvt *pe, int redraw)
{
    long r;
    unsigned long t;
    int len;
    unsigned int n;
    unsigned char rd;

    rd = redraw;
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
                if (rd == 1)
                    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                return;
            }
            if ((len = ((int (__cdecl *)(char *))HDAE5000_StrLen)((char *)ram_230636)) > 39)
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
                    if (rd == 1)
                        CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                }
            }
            ram_23087a.x = ram_2307b8[LYR_LEN((unsigned int)ram_2304d8.s.line)] + ram_23080e[ram_2304d8.s.col];
            ram_23087a.y = ram_230808[ram_2304d8.s.line];
            ram_2304d8.s.col += len;
            ram_2304d8.s.hilite = 1;
            if (rd == 1)
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
                        if (rd == 1)
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

long HDAE5000_Lyrics_FillLines(int scroll, unsigned int pos)
{
    int slot;
    unsigned int cur;
    long r;
    unsigned long savetick;
    unsigned long savenext;
    char line[40];
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
        if (ram_230636[0] != 0x0d)
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
    if (ram_230636[0] != 0x0a)
        goto other;
    cur = r;
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete);
    goto store;
other:
    if (HDAE5000_StrLen((char *)ram_230636) > 39) {
        cur = r;
        goto top;
    }
    n = HDAE5000_StrLen(line);
    if (HDAE5000_StrLen((char *)ram_230636) + n > 39)
        goto tail;
    HDAE5000_StrCat(line, (char *)ram_230636);
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

/* cc900-name: Lyr_FillLines_v1=HDAE5000_Lyrics_FillLines */
long Lyr_FillLines_v1(int scroll, unsigned int pos)
{
    int slot;
    unsigned int cur;
    long r;
    unsigned long savetick;
    unsigned long savenext;
    char line[40];
    unsigned char first;
    unsigned int n;

    savetick = HDAE5000_RAM_LyricEvent.tick;
    savenext = HDAE5000_RAM_LyricEvent.nexttick;
    if ((char)scroll == 1) {
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
        if (ram_230636[0] != 0x0d)
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
    if (ram_230636[0] != 0x0a)
        goto other;
    cur = r;
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete);
    goto store;
other:
    if (HDAE5000_StrLen((char *)ram_230636) > 39) {
        cur = r;
        goto top;
    }
    n = HDAE5000_StrLen(line);
    if (HDAE5000_StrLen((char *)ram_230636) + n > 39)
        goto tail;
    HDAE5000_StrCat(line, (char *)ram_230636);
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

/* cc900-name: Lyr_FillLines_v2=HDAE5000_Lyrics_FillLines */
long Lyr_FillLines_v2(unsigned char scroll, unsigned int pos)
{
    int slot;
    unsigned int cur;
    long r;
    unsigned long savetick;
    unsigned long savenext;
    char line[40];
    unsigned char first;
    unsigned int n;

    savetick = HDAE5000_RAM_LyricEvent.tick;
    savenext = HDAE5000_RAM_LyricEvent.nexttick;
    if (scroll == 1) {
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
        if (ram_230636[0] != 0x0d)
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
    if (ram_230636[0] != 0x0a)
        goto other;
    cur = r;
    HDAE5000_StrCpy(HDAE5000_RAM_LyricLines[slot], HDAE5000_Str_Empty_File_Delete);
    goto store;
other:
    if (HDAE5000_StrLen((char *)ram_230636) > 39) {
        cur = r;
        goto top;
    }
    n = HDAE5000_StrLen(line);
    if (HDAE5000_StrLen((char *)ram_230636) + n > 39)
        goto tail;
    HDAE5000_StrCat(line, (char *)ram_230636);
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

unsigned int HDAE5000_Lyrics_ParseEvent(int flags, unsigned int pos)
{
    unsigned int p;
    unsigned char keep;
    long n;
    unsigned int ps;
    unsigned char f;

    ps = pos;
    f = flags;
    keep = 0;
    if (ps + 4 > 20457) {
        ram_2307b6 = 0xffff;
        return 0;
    }
    p = ps;
    if ((f & 1) == 1)
        keep = 1;
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.prevpos = HDAE5000_RAM_LyricEvent.pos;
        HDAE5000_RAM_LyricEvent.pos = ps;
    }
    if ((ram_230860 = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffe;
        return 0;
    }
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.l24 = HDAE5000_RAM_LyricEvent.tick;
        HDAE5000_RAM_LyricEvent.l36 = HDAE5000_RAM_LyricEvent.l28;
        HDAE5000_RAM_LyricEvent.l28 = ram_230860;
    }
    HDAE5000_RAM_LyricEvent.tick += ram_230860;
    p += ram_23085e;
    if (LYRIC_EV(p++) != 0xff) {
        ram_2307b6 = 0xfffd;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.type = LYRIC_EV(p++);
    if (HDAE5000_RAM_LyricEvent.type == 47) {
        HDAE5000_RAM_LyricEvent.eot = 1;
        ram_230860 = -1L;
        return 0;
    }
    if ((n = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffc;
        return 0;
    }
    p += ram_23085e;
    HDAE5000_RAM_LyricEvent.len = n;
    if (p + HDAE5000_RAM_LyricEvent.len > 20457) {
        ram_2307b6 = 0xfffb;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.endpos = p + HDAE5000_RAM_LyricEvent.len;
    if ((HDAE5000_RAM_LyricEvent.l32 = HDAE5000_Lyrics_ReadVarLen(p + HDAE5000_RAM_LyricEvent.len)) == -1L) {
        ram_2307b6 = 0xfffa;
        return 0;
    }
    ram_230882 = LYRIC_EV(p + HDAE5000_RAM_LyricEvent.len + ram_23085e + 4);
    if (keep == 1) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            (&HDAE5000_RAM_LyricEvent.data[0])[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), 127);
            HDAE5000_RAM_LyricEvent.data[127] = 0;
        }
    }
    HDAE5000_RAM_LyricEvent.nexttick = HDAE5000_RAM_LyricEvent.l32 + HDAE5000_RAM_LyricEvent.tick;
    if ((f & 2) == 2) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            ram_230636[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), 127);
            ram_230636[127] = 0;
        }
    }
    return HDAE5000_RAM_LyricEvent.endpos - ps;
}

/* cc900-name: Lyr_ParseEvent_v1=HDAE5000_Lyrics_ParseEvent */
unsigned int Lyr_ParseEvent_v1(int flags, unsigned int pos)
{
    unsigned int p;
    unsigned char keep;
    long n;

    keep = 0;
    if (pos + 4 > 20457) {
        ram_2307b6 = 0xffff;
        return 0;
    }
    p = pos;
    if (((unsigned char)flags & 1) == 1)
        keep = 1;
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.prevpos = HDAE5000_RAM_LyricEvent.pos;
        HDAE5000_RAM_LyricEvent.pos = pos;
    }
    if ((ram_230860 = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffe;
        return 0;
    }
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.l24 = HDAE5000_RAM_LyricEvent.tick;
        HDAE5000_RAM_LyricEvent.l36 = HDAE5000_RAM_LyricEvent.l28;
        HDAE5000_RAM_LyricEvent.l28 = ram_230860;
    }
    HDAE5000_RAM_LyricEvent.tick += ram_230860;
    p += ram_23085e;
    if (LYRIC_EV(p++) != 0xff) {
        ram_2307b6 = 0xfffd;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.type = LYRIC_EV(p++);
    if (HDAE5000_RAM_LyricEvent.type == 47) {
        HDAE5000_RAM_LyricEvent.eot = 1;
        ram_230860 = -1L;
        return 0;
    }
    if ((n = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffc;
        return 0;
    }
    p += ram_23085e;
    HDAE5000_RAM_LyricEvent.len = n;
    if (p + HDAE5000_RAM_LyricEvent.len > 20457) {
        ram_2307b6 = 0xfffb;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.endpos = p + HDAE5000_RAM_LyricEvent.len;
    if ((HDAE5000_RAM_LyricEvent.l32 = HDAE5000_Lyrics_ReadVarLen(p + HDAE5000_RAM_LyricEvent.len)) == -1L) {
        ram_2307b6 = 0xfffa;
        return 0;
    }
    ram_230882 = LYRIC_EV(p + HDAE5000_RAM_LyricEvent.len + ram_23085e + 4);
    if (keep == 1) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            (&HDAE5000_RAM_LyricEvent.data[0])[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), 127);
            HDAE5000_RAM_LyricEvent.data[127] = 0;
        }
    }
    HDAE5000_RAM_LyricEvent.nexttick = HDAE5000_RAM_LyricEvent.l32 + HDAE5000_RAM_LyricEvent.tick;
    if (((unsigned char)flags & 2) == 2) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            ram_230636[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), 127);
            ram_230636[127] = 0;
        }
    }
    return HDAE5000_RAM_LyricEvent.endpos - pos;
}

/* cc900-name: Lyr_ParseEvent_v2=HDAE5000_Lyrics_ParseEvent */
unsigned int Lyr_ParseEvent_v2(unsigned char flags, unsigned int pos)
{
    unsigned int p;
    unsigned char keep;
    long n;

    keep = 0;
    if (pos + 4 > 20457) {
        ram_2307b6 = 0xffff;
        return 0;
    }
    p = pos;
    if ((flags & 1) == 1)
        keep = 1;
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.prevpos = HDAE5000_RAM_LyricEvent.pos;
        HDAE5000_RAM_LyricEvent.pos = pos;
    }
    if ((ram_230860 = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffe;
        return 0;
    }
    if (keep == 1) {
        HDAE5000_RAM_LyricEvent.l24 = HDAE5000_RAM_LyricEvent.tick;
        HDAE5000_RAM_LyricEvent.l36 = HDAE5000_RAM_LyricEvent.l28;
        HDAE5000_RAM_LyricEvent.l28 = ram_230860;
    }
    HDAE5000_RAM_LyricEvent.tick += ram_230860;
    p += ram_23085e;
    if (LYRIC_EV(p++) != 0xff) {
        ram_2307b6 = 0xfffd;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.type = LYRIC_EV(p++);
    if (HDAE5000_RAM_LyricEvent.type == 47) {
        HDAE5000_RAM_LyricEvent.eot = 1;
        ram_230860 = -1L;
        return 0;
    }
    if ((n = HDAE5000_Lyrics_ReadVarLen(p)) == -1L) {
        ram_2307b6 = 0xfffc;
        return 0;
    }
    p += ram_23085e;
    HDAE5000_RAM_LyricEvent.len = n;
    if (p + HDAE5000_RAM_LyricEvent.len > 20457) {
        ram_2307b6 = 0xfffb;
        return 0;
    }
    HDAE5000_RAM_LyricEvent.endpos = p + HDAE5000_RAM_LyricEvent.len;
    if ((HDAE5000_RAM_LyricEvent.l32 = HDAE5000_Lyrics_ReadVarLen(p + HDAE5000_RAM_LyricEvent.len)) == -1L) {
        ram_2307b6 = 0xfffa;
        return 0;
    }
    ram_230882 = LYRIC_EV(p + HDAE5000_RAM_LyricEvent.len + ram_23085e + 4);
    if (keep == 1) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            (&HDAE5000_RAM_LyricEvent.data[0])[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_LyricEvent.data, &LYRIC_EV(p), 127);
            HDAE5000_RAM_LyricEvent.data[127] = 0;
        }
    }
    HDAE5000_RAM_LyricEvent.nexttick = HDAE5000_RAM_LyricEvent.l32 + HDAE5000_RAM_LyricEvent.tick;
    if ((flags & 2) == 2) {
        if (HDAE5000_RAM_LyricEvent.len <= 127) {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), (unsigned long)HDAE5000_RAM_LyricEvent.len);
            ram_230636[HDAE5000_RAM_LyricEvent.len] = 0;
        } else {
            HDAE5000_MemCopy(ram_230636, &LYRIC_EV(p), 127);
            ram_230636[127] = 0;
        }
    }
    return HDAE5000_RAM_LyricEvent.endpos - pos;
}
