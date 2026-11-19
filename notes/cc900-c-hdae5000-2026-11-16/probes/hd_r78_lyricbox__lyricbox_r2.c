/* Functions of hdae5000_ui_display.s.  (hdae5000_lyricbox.c, ported to hdae5000_v2_01i)
   Firmware C (cc900 phase 6), built by Toshiba V4.23.
   cc900-options: -Xr
   cc900-module: HDAE5000_Lyrics_ResetState HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ClearBuffer
   cc900-data: HDAE5000_LyricBoxProc 1 = HDAE5000_LyricBoxProc_CaseTable2
   cc900-data: HDAE5000_LyricBoxProc 2 = HDAE5000_LyricBoxProc_CaseTable1
   v2.01i:
   - the text lines are 35 bytes (LyricLines[6][35]: the row address is a HDAE5000_Multiply call by 35 where v2.06i
     shifts for 40, which is why the ROM spills the first DrawString argument to a stack temp, keeps &pt in XIZ
     and the loop counter i in a stack slot); the blank line is HDAE5000_Str_Blank34; the column tables have 35
     entries (34 columns: k < 34, x from box.x1 + 136);
   - the colours are not the ram_23087e / ram_230880 bytes (v2.01i has no colour settings): DrawString takes the
     view instance's words at +38 (foreground, highlighted text) and +36 (background): LyrView a38 / a36;
   - the blank / syllable strings are passed without the (long) cast (the ROM loads them straight into XDE,
     `lda xde,sym`; v2.06i's (long) gave `lda xwa,sym; ld xde,xwa`);
   - the text buffers at 0x23051a: syllable 246, event data 128, info 128 (0x230690), conductor 36 (0x230710),
     title 24 (0x230734), time signature 10 (0x23074c), measure 10 (0x230756); the other cells moved
     (ram_<hex> below), and the UI object ids come from this tree's hdae_ids.h.
   round 2 (run 2026-11-19-62: llvm-mc could not place the relaxed body; the one code difference was the
   blank line's DrawString): the ROM loads the blank line in argument order straight into XDE (`lda xhl,box;
   lda xbc,&pt; lda xde,Blank34`), as for the member arrays ram_23051a.syl / .info; the plain extern array
   was loaded last, after the pushes, and the box went to XDE.  This form: HDAE5000_Str_Blank34 as a one-member struct, .s passed.
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
/* the lyric box's view instance (RootFn_GetViewInstance) */
struct LyrView { char p0[22]; int a22; char p1[4]; int *flag; long l32; int a36; int a38; long l40; int a44; };
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };
/* 0x22a088 */
struct LyrBox {
    struct LyrView *v;
    struct Box box;             /* +4  the text area */
    struct Box frame;           /* +12 */
    struct Point title;         /* +20 */
    struct Box mbox;            /* +24 measure */
    struct Point mpt;           /* +32 */
    struct Box tbox;            /* +36 time signature */
    struct Point tpt;           /* +44 */
    int w48;                    /* +48 */
};
/* 0x23051a */
struct LyrText {
    char syl[246];
    char chord[128];            /* 0x230610 */
    char info[128];             /* 0x230690 */
    char cond[36];              /* 0x230710 */
    char title[24];             /* 0x230734 */
    char tsig[10];              /* 0x23074c */
    char meas[10];              /* 0x230756 */
};
/* 0x23081e */
struct LyrTick { unsigned long tick; struct Point pos; };

extern char HDAE5000_RAM_LyricLines[6][35];
extern long HDAE5000_RAM_LyricBoxObj;
/* line state at 0x2304d8: +16 the length of each of the 6 text lines, +22 the current line */
extern unsigned char ram_2304d8[];
extern struct LyrBox ram_22a088;
extern struct LyrText ram_23051a;
extern struct LyrTick ram_23081e;
extern unsigned char ram_230760, ram_230762;
extern unsigned int ram_230766, ram_230768, ram_23076a, ram_23076c, ram_23076e, ram_230770;
extern int ram_230774[35];
extern int ram_230776[34];
extern int ram_2307b8;
extern unsigned char ram_2307ba[6];
extern int ram_2307c0[34];
extern unsigned int ram_230818, ram_23081a, ram_23081c;
extern unsigned char ram_23a104;

/* the blank line as a member array at offset 0 (the shape of ram_23051a.syl) */
extern struct Blank34 { char s[35]; } HDAE5000_Str_Blank34;
extern char HDAE5000_Str_Reset[], HDAE5000_Str_Load[], HDAE5000_Fmt_03i_i[];

void HDAE5000_Lyrics_ClearBuffer(void);
void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *, int);
long HDAE5000_Lyrics_ResetState(void);
long HDAE5000_Lyrics_ReadSongInfo(long);
long HDAE5000_Lyrics_FillLines(int, unsigned int);

long HDAE5000_LyricBoxProc(long obj, long ev, long p)
{
    struct Point pt;
    struct LyrView *v;
    int k;
    unsigned int i;

    switch (ev) {
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, p);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
        return 0;
    case EVT_PAINT:
        CALLV(ROOT->InheritedProc)(obj, ev, p);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRIC_PARAM, 0L);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRICS, 0L);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_LYRIC_ALL_DRAW, 1L);
        return 0;
    case EVT_HDAE_INIT_LYRIC_PARAM:
        if (ram_23a104 == 0) {
            ram_23a104 = 1;
            CALLV(ROOT->GetClientBox)(obj, (long)&ram_22a088.box);
            ram_22a088.box.x1 += 2;
            ram_22a088.box.y1 += 4;
            ram_22a088.box.x2 -= 1;
            ram_22a088.box.y2 -= 2;
            ram_22a088.frame.x1 = ram_22a088.box.x1 + 2;
            ram_22a088.frame.y1 = ram_22a088.box.y1 - 2;
            ram_22a088.frame.x2 = ram_22a088.box.x2 - 2;
            ram_22a088.frame.y2 = ram_22a088.frame.y1 + 13;
            ram_22a088.title.x = ram_22a088.box.x1 + 6;
            ram_22a088.title.y = ram_22a088.box.y1 + 2;
            CALLV(ROOT->GetClientBox)(OBJ_MeasureinLyric, (long)&ram_22a088.mbox);
            ram_22a088.mpt.x = ram_22a088.mbox.x1 + 20;
            ram_22a088.mpt.y = ram_22a088.mbox.y1 + 5;
            CALLV(ROOT->GetClientBox)(OBJ_TimeSigInLyric, (long)&ram_22a088.tbox);
            ram_22a088.tpt.x = ram_22a088.tbox.x1 + 20;
            ram_22a088.tpt.y = ram_22a088.tbox.y1 + 5;
            ram_230774[0] = 0;
            for (k = 0; k < 34; k++)
                ram_230776[k] = ram_22a088.box.x1 + 136 - (k * 4 + 4);
            for (k = 0; k < 34; k++)
                ram_2307c0[k] = k << 3;
            for (k = 0; k < 6; k++)
                ram_2307ba[k] = (unsigned char)(ram_22a088.box.y1 + k * 18) + 15;
        }
        return 0;
    case EVT_HDAE_INIT_LYRICS:
        switch (p) {
        default:
            return 0;
        case 0:
            if (ram_23076e != 0) {
                ram_23076e = 0;
                ram_230770 = 1;
                HDAE5000_Lyrics_ResetState();
                HDAE5000_Lyrics_ReadSongInfo(0L);
                ram_22a088.w48 = 0;
                ram_230818 = HDAE5000_Lyrics_FillLines(0, 0);
                CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
                ram_230770 = 0;
            }
            return 0;
        case 1:
            HDAE5000_Lyrics_ResetState();
            HDAE5000_Lyrics_ReadSongInfo(0L);
            ram_22a088.w48 = 0;
            CALLV(ROOT->SendEvent)(obj, EVT_PAINT, 0L);
            return 0;
        }
    case EVT_HDAE_LYRIC_ALL_DRAW:
        v = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj);
        ram_22a088.v = v;
        for (i = 0; i < 6; i++) {
            ram_2304d8[(unsigned long)i + 16] = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[i]);
            pt.x = ram_2307b8;
            pt.y = ram_2307ba[i];
            CALLV(ROOT->DrawString)(&ram_22a088.box, &pt.x, HDAE5000_Str_Blank34.s, ram_22a088.v->l32,
                                    ram_22a088.v->a36, ram_22a088.v->a22);
            pt.x = ram_230774[ram_2304d8[(unsigned long)i + 16]];
            if (ram_2304d8[22] > i)
                CALLV(ROOT->DrawString)(&ram_22a088.box, &pt.x, HDAE5000_RAM_LyricLines[i], ram_22a088.v->l32,
                                        ram_22a088.v->a38, ram_22a088.v->a22);
            else
                CALLV(ROOT->DrawString)(&ram_22a088.box, &pt.x, HDAE5000_RAM_LyricLines[i], ram_22a088.v->l32,
                                        ram_22a088.v->a36, ram_22a088.v->a22);
        }
        CALLV(ROOT->DrawFrame)(&ram_22a088.frame, 0xf9);
        CALLV(ROOT->DrawString)(&ram_22a088.box, &ram_22a088.title, ram_23051a.info, ram_22a088.v->l40,
                                ram_22a088.v->a44, ram_22a088.v->a22);
        if (p == 1) {
            CALLV(ROOT->SendEvent)(OBJ_Conductor, EVT_PARA_DRAW, (long)ram_23051a.cond);
            CALLV(ROOT->SendEvent)(OBJ_SongTitle, EVT_PARA_DRAW, (long)ram_23051a.title);
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_SYLLABLE, 4L);
            CALLV(ROOT->SendEvent)(OBJ_bottom01, EVT_PARA_DRAW, (long)HDAE5000_Str_Reset);
            CALLV(ROOT->SendEvent)(OBJ_bottom08, EVT_PARA_DRAW, (long)HDAE5000_Str_Load);
        }
        return 0;
    case EVT_HDAE_DRAW_SYLLABLE:
        switch (p) {
        case 0:
            CALLV(ROOT->DrawString)(&ram_22a088.box, &ram_23081e.pos, ram_23051a.syl, ram_22a088.v->l32,
                                    ram_22a088.v->a38, ram_22a088.v->a22);
        default:
        inherited:
            return CALLR(long, ROOT->InheritedProc)(obj, ev, p);
        case 1:
            CALLV(ROOT->DrawString)(&ram_22a088.box, &ram_23081e.pos, ram_23051a.syl, ram_22a088.v->l32,
                                    ram_22a088.v->a36, ram_22a088.v->a22);
            goto inherited;
        case 2:
            CALLV(ROOT->DrawString)(&ram_22a088.box, &ram_22a088.title, ram_23051a.info, ram_22a088.v->l40,
                                    ram_22a088.v->a44, ram_22a088.v->a22);
            goto inherited;
        case 3:
            CALLV(ROOT->DrawString)((long)&ram_22a088.mbox, (long)&ram_22a088.mpt, (long)ram_23051a.meas,
                                    ram_22a088.v->l40, 0xff, 8);
            goto inherited;
        case 4:
            CALLV(ROOT->DrawString)((long)&ram_22a088.tbox, (long)&ram_22a088.tpt, (long)ram_23051a.tsig,
                                    ram_22a088.v->l40, 0xff, 8);
            goto inherited;
        }
    default:
        goto inherited;
    case EVT_HDAE_TICKS:
        if (ram_230770 != 0)
            goto inherited;
        HDAE5000_Lyrics_PlayToPosition((struct LyricPosEvt *)p, 1);
        if (ram_23081c >= ram_23076c) {
            ram_23076c = ram_23076a;
            ram_23081a++;
            ram_23081c = 0;
            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_BEAT_MESSAGE, 0L);
        }
        ram_23081c++;
        ram_23081e.tick += 1;
        goto inherited;
    case EVT_HDAE_BEAT_MESSAGE:
        ram_230768++;
        if (ram_230768 > ram_230762) {
            ram_230762 = ram_230760;
            ram_230766++;
            ram_230768 = 1;
        }
        HDAE5000_SPrintf((void *)ram_23051a.meas, HDAE5000_Fmt_03i_i, (int)ram_230766, (int)ram_230768);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_SYLLABLE, 3L);
        goto inherited;
    case EVT_SHOW:
        *(ram_22a088.v = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj))->flag = 1;
        HDAE5000_RAM_LyricBoxObj = obj;
        ram_23076e = 1;
        goto inherited;
    case EVT_HIDE:
        *(ram_22a088.v = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj))->flag = 0;
        HDAE5000_RAM_LyricBoxObj = -1L;
        goto inherited;
    case EVT_SW_IN:
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, p)) {
        case 0:
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRICS, 1L);
            ram_230818 = HDAE5000_Lyrics_FillLines(0, 0);
            CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
            break;
        case 7:
            v = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj);
            ram_22a088.v = v;
            HDAE5000_Lyrics_ClearBuffer();
            CALLV(ROOT->ApPostEvent)(OBJ_LoadLyricFD, EVT_SHOW, 0L);
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
            ;
        }
        return 0;
    }
}
