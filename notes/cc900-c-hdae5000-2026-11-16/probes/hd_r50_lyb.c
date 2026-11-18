/* lane_hd round 50, helper h_lyb, form a: HDAE5000_LyricBoxProc alone (hdae5000_ui_display.s, 0x28cd08, 2227 B with
   its arms _Ev01C0000D .. _Epilogue: one frame, one epilogue, two jump tables).
   cc900-options: -Xr
   cc900-data: HDAE5000_LyricBoxProc 1 = HDAE5000_LyricBoxProc_CaseTable1
   cc900-data: HDAE5000_LyricBoxProc 2 = HDAE5000_LyricBoxProc_CaseTable2
   cc900-module: HDAE5000_Lyrics_ResetState HDAE5000_Lyrics_ReadSongInfo HDAE5000_Lyrics_FillLines
   cc900-module: HDAE5000_Lyrics_PlayToPosition HDAE5000_Lyrics_ClearBuffer
   Changes against hd_r13_lyra.c's LyricBoxProc (run 2026-11-16-75, DIFF from +23 on; its listing read with a byte
   alignment against the ROM):
   - DrawString's stack arguments are pushed left to right (FDFileSelectProc's matched (.., 3L, 0xff, 0xf5) pushes
     3L first): the ROM pushes the view's long first and its word at +22 last, so the order is (.., l32 or l40,
     colour, a22 / a44 / 8); r13 had them reversed;
   - the third DrawString / SendEvent argument cast (long) where the ROM loads it through XWA (`lda xwa,(buf);
     ld xde,xwa`), plain where it loads XDE directly (ram_2306b6); likewise (long)& for the boxes of
     GetClientBox and of the DRAW_SYLLABLE 3 / 4 cases (`lda xwa,(box); ld xhl / xbc,xwa`);
   - GetViewInstance's result through a local v (FDFileSelectProc's `v = CALLR(..)` loads the function into XIX,
     as the ROM does here; r13's `ram_22a088 = CALLR(..)` gave XHL);
   - the line lengths as a flat byte array indexed (unsigned long)i + 16 (ROM extz xwa; add xwa,16; ld xbc,imm;
     add xbc,xwa); the current line is byte 22 of it;
   - SPrintf's buffer (void *) and its counters (int) (ROM lda xwa,(buf); push xwa and ld wa,(n); pushw wa);
   - the y-row table: (unsigned char)(y1 + k * 18) + 15 (ROM muls wa,18; add wa,(y1); add a,15: the 16-bit sum
     narrowed only for the +15; r13's k * 18 + y1 + 15 was narrowed to a byte mul throughout);
   - the edit-switch switch gets cases 1..6 as empty labels after case 7: CaseTable2 has 8 entries, 1..6 = the end
     (a switch of 2 cases is a compare chain; 5 cases 0..4 are still a chain in the ROM, 6 (Lbn_StepDigit) a table);
   - DRAW_SYLLABLE: the ROM lays out case 0, then the inherited call, then cases 1..4 (each jumping back to it): the
     inherited call is the inner switch's default, placed after case 0.  The outer switch's default must reach the
     same code; C cannot put the outer default inside the inner switch, so it is `default: goto inherited;` after
     case 4.  This matches only if V4.23 sends the dispatch straight to `inherited` and drops the unreachable jump
     (unknown; otherwise expect a 3-byte jrl too many after case 4 and the table / range targets on it). */
#include "hdae_ws.h"
#include "hdae_ids.h"

extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);

struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
/* the lyric box's view instance (RootFn_GetViewInstance) */
struct LyrView { char p0[22]; int a22; char p1[4]; int *flag; long l32; char p2[4]; long l40; int a44; };
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };

extern char HDAE5000_RAM_LyricLines[6][40];
extern long HDAE5000_RAM_LyricBoxObj;
/* line state at 0x2304d8: +16 the length of each of the 6 text lines, +22 the current line */
extern unsigned char ram_2304d8[];
extern struct LyrView *ram_22a088;
extern struct Box ram_22a08c, ram_22a094, ram_22a0a0, ram_22a0ac;
extern struct Point ram_22a09c, ram_22a0a8, ram_22a0b4, ram_23087a;
extern int ram_22a0b8;
extern char ram_23051e[];
extern char ram_2306b6[128];
extern char ram_230736[50];
extern char ram_230768[40];
extern char ram_230790[10];
extern char ram_23079a[10];
extern unsigned char ram_2307a4, ram_2307a6;
extern unsigned int ram_2307aa, ram_2307ac, ram_2307ae, ram_2307b0, ram_2307b2, ram_2307b4;
extern int ram_2307b8[40];
extern int ram_2307ba[39];
extern int ram_230806;
extern unsigned char ram_230808[6];
extern int ram_23080e[39];
extern unsigned int ram_230870, ram_230872, ram_230874;
extern unsigned long ram_230876;
extern unsigned char ram_23087e, ram_230880;
extern unsigned char ram_23a19a;

extern char HDAE5000_Str_Blank40[], HDAE5000_Str_Reset[], HDAE5000_Str_Load[], HDAE5000_Fmt_03i_i[];

void HDAE5000_Lyrics_ClearBuffer(void);
void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *, int);
long HDAE5000_Lyrics_ResetState(void);
long HDAE5000_Lyrics_ReadSongInfo(long);
long HDAE5000_Lyrics_FillLines(int, unsigned int);

/* source order DRAW, PAINT, 3, 7, 8, 9 (with the inherited call), 4, 5, SHOW, HIDE, SW_IN: V4.23 compares the
   cases in reverse source order (SW_IN, HIDE, SHOW, PAINT, DRAW, then the 3..9 table) and lays the bodies out in
   source order */
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
        if (ram_23a19a == 0) {
            ram_23a19a = 1;
            CALLV(ROOT->GetClientBox)(obj, (long)&ram_22a08c);
            ram_22a08c.x1 += 2;
            ram_22a08c.y1 += 4;
            ram_22a08c.x2 -= 1;
            ram_22a08c.y2 -= 2;
            ram_22a094.x1 = ram_22a08c.x1 + 2;
            ram_22a094.y1 = ram_22a08c.y1 - 2;
            ram_22a094.x2 = ram_22a08c.x2 - 2;
            ram_22a094.y2 = ram_22a094.y1 + 13;
            ram_22a09c.x = ram_22a08c.x1 + 6;
            ram_22a09c.y = ram_22a08c.y1 + 2;
            CALLV(ROOT->GetClientBox)(OBJ_MeasureinLyric, (long)&ram_22a0a0);
            ram_22a0a8.x = ram_22a0a0.x1 + 20;
            ram_22a0a8.y = ram_22a0a0.y1 + 5;
            CALLV(ROOT->GetClientBox)(OBJ_TimeSigInLyric, (long)&ram_22a0ac);
            ram_22a0b4.x = ram_22a0ac.x1 + 20;
            ram_22a0b4.y = ram_22a0ac.y1 + 5;
            ram_2307b8[0] = 0;
            for (k = 0; k < 39; k++)
                ram_2307ba[k] = ram_22a08c.x1 + 156 - (k * 4 + 4);
            for (k = 0; k < 39; k++)
                ram_23080e[k] = k << 3;
            for (k = 0; k < 6; k++)
                ram_230808[k] = (unsigned char)(ram_22a08c.y1 + k * 18) + 15;
        }
        return 0;
    case EVT_HDAE_INIT_LYRICS:
        switch (p) {
        default:
            return 0;
        case 0:
            if (ram_2307b2 != 0) {
                ram_2307b2 = 0;
                ram_2307b4 = 1;
                HDAE5000_Lyrics_ResetState();
                HDAE5000_Lyrics_ReadSongInfo(0L);
                ram_22a0b8 = 0;
                ram_230870 = HDAE5000_Lyrics_FillLines(0, 0);
                CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
                ram_2307b4 = 0;
            }
            return 0;
        case 1:
            HDAE5000_Lyrics_ResetState();
            HDAE5000_Lyrics_ReadSongInfo(0L);
            ram_22a0b8 = 0;
            CALLV(ROOT->SendEvent)(obj, EVT_PAINT, 0L);
            return 0;
        }
    case EVT_HDAE_LYRIC_ALL_DRAW:
        v = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj);
        ram_22a088 = v;
        for (i = 0; i < 6; i++) {
            ram_2304d8[(unsigned long)i + 16] = HDAE5000_StrLen(HDAE5000_RAM_LyricLines[i]);
            pt.x = ram_230806;
            pt.y = ram_230808[i];
            CALLV(ROOT->DrawString)(&ram_22a08c, &pt, (long)HDAE5000_Str_Blank40, ram_22a088->l32, ram_230880,
                                    ram_22a088->a22);
            pt.x = ram_2307b8[ram_2304d8[(unsigned long)i + 16]];
            if (ram_2304d8[22] > i)
                CALLV(ROOT->DrawString)(&ram_22a08c, &pt, HDAE5000_RAM_LyricLines[i], ram_22a088->l32, ram_23087e,
                                        ram_22a088->a22);
            else
                CALLV(ROOT->DrawString)(&ram_22a08c, &pt, HDAE5000_RAM_LyricLines[i], ram_22a088->l32, ram_230880,
                                        ram_22a088->a22);
        }
        CALLV(ROOT->DrawFrame)(&ram_22a094, 0xf9);
        CALLV(ROOT->DrawString)(&ram_22a08c, &ram_22a09c, ram_2306b6, ram_22a088->l40, ram_22a088->a44,
                                ram_22a088->a22);
        if (p == 1) {
            CALLV(ROOT->SendEvent)(OBJ_Conductor, EVT_PARA_DRAW, (long)ram_230736);
            CALLV(ROOT->SendEvent)(OBJ_SongTitle, EVT_PARA_DRAW, (long)ram_230768);
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_SYLLABLE, 4L);
            CALLV(ROOT->SendEvent)(OBJ_bottom01, EVT_PARA_DRAW, (long)HDAE5000_Str_Reset);
            CALLV(ROOT->SendEvent)(OBJ_bottom08, EVT_PARA_DRAW, (long)HDAE5000_Str_Load);
        }
        return 0;
    case EVT_HDAE_DRAW_SYLLABLE:
        switch (p) {
        case 0:
            CALLV(ROOT->DrawString)(&ram_22a08c, &ram_23087a, (long)ram_23051e, ram_22a088->l32, ram_23087e,
                                    ram_22a088->a22);
        default:
        inherited:
            return CALLR(long, ROOT->InheritedProc)(obj, ev, p);
        case 1:
            CALLV(ROOT->DrawString)(&ram_22a08c, &ram_23087a, (long)ram_23051e, ram_22a088->l32, ram_230880,
                                    ram_22a088->a22);
            goto inherited;
        case 2:
            CALLV(ROOT->DrawString)(&ram_22a08c, &ram_22a09c, ram_2306b6, ram_22a088->l40, ram_22a088->a44,
                                    ram_22a088->a22);
            goto inherited;
        case 3:
            CALLV(ROOT->DrawString)((long)&ram_22a0a0, (long)&ram_22a0a8, (long)ram_23079a, ram_22a088->l40, 0xff, 8);
            goto inherited;
        case 4:
            CALLV(ROOT->DrawString)((long)&ram_22a0ac, (long)&ram_22a0b4, (long)ram_230790, ram_22a088->l40, 0xff, 8);
            goto inherited;
        }
    default:
        goto inherited;
    case EVT_HDAE_TICKS:
        if (ram_2307b4 != 0)
            goto inherited;
        HDAE5000_Lyrics_PlayToPosition((struct LyricPosEvt *)p, 1);
        if (ram_230874 >= ram_2307b0) {
            ram_2307b0 = ram_2307ae;
            ram_230872++;
            ram_230874 = 0;
            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_BEAT_MESSAGE, 0L);
        }
        ram_230874++;
        ram_230876 += 1;
        goto inherited;
    case EVT_HDAE_BEAT_MESSAGE:
        ram_2307ac++;
        if (ram_2307ac > ram_2307a6) {
            ram_2307a6 = ram_2307a4;
            ram_2307aa++;
            ram_2307ac = 1;
        }
        HDAE5000_SPrintf((void *)ram_23079a, HDAE5000_Fmt_03i_i, (int)ram_2307aa, (int)ram_2307ac);
        CALLV(ROOT->SendEvent)(obj, EVT_HDAE_DRAW_SYLLABLE, 3L);
        goto inherited;
    case EVT_SHOW:
        *(ram_22a088 = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj))->flag = 1;
        HDAE5000_RAM_LyricBoxObj = obj;
        ram_2307b2 = 1;
        goto inherited;
    case EVT_HIDE:
        *(ram_22a088 = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj))->flag = 0;
        HDAE5000_RAM_LyricBoxObj = -1L;
        goto inherited;
    case EVT_SW_IN:
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, p)) {
        case 0:
            CALLV(ROOT->SendEvent)(obj, EVT_HDAE_INIT_LYRICS, 1L);
            ram_230870 = HDAE5000_Lyrics_FillLines(0, 0);
            CALLV(ROOT->SendEvent)(obj, EVT_DRAW, 0L);
            break;
        case 7:
            v = CALLR(struct LyrView *, ROOT->GetViewInstance)(obj);
            ram_22a088 = v;
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
