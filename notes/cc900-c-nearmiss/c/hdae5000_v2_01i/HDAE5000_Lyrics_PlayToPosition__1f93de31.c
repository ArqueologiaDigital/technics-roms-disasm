/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_lyrics_play.c (2026-11-19-46-hd-r68-learned-ports)
   sha256 1f93de313d92b9c95e5d5cb5b5b107e4e7307f1a8204c09ae789fd24c5428e08 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: Lyr_PlayToPos_l=HDAE5000_Lyrics_PlayToPosition */
struct RootFns {
    void *pad0[33];
    void *UpdateScreen;
    void *pad1[5];
    void *DrawLine;
    void *pad2[1];
    void *DrawBox;
    void *DrawFrame;
    void *pad3[1];
    void *MovePixels;
    void *pad4[4];
    void *DrawString;
    void *pad5[5];
    void *InheritedProc;
    void *pad6[1];
    void *RegisterObjectTable;
    void *pad7[6];
    void *SendEvent;
    void *PostEvent;
    void *pad8[7];
    void *ApPostEvent;
    void *pad9[5];
    void *ResEventProc;
    void *ResMethodProc;
    void *pad10[1];
    void *ResNameProc;
    void *pad11[1];
    void *GetCharHeight;
    void *GetCharDescent;
    void *GetCenteredDelta;
    void *ConvertStrings;
    void *pad12[2];
    void *ClassProc;
    void *pad13[54];
    void *FunctionProc;
    void *ApFunctionProc;
    void *MainFunctionProc;
    void *ApFuncCall;
    void *MainFuncCall;
    void *pad14[6];
    void *RegisterTitle;
    void *pad15[1];
    void *GetTitleNow;
    void *pad16[1];
    void *ViewableProc;
    void *pad17[4];
    void *SetVisible;
    void *pad18[11];
    void *GetViewInstance;
    void *pad19[3];
    void *GetClientBox;
    void *pad20[1];
    void *DrawDesignBox;
    void *pad21[57];
    void *SetDialEnable;
    void *SetDialUp;
    void *SetDialDown;
    void *pad22[16];
    void *SetApTimer;
    void *pad23[1];
    void *KillApTimer;
    void *pad24[4];
    void *SetAutoInc;
    void *pad25[55];
    void *GetNamingWindowID;
    void *pad26[9];
    void *DeleteEvent;
    void *SleepMainTask;
    void *WakeUpMainTask;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define CALLV(f) ((void (*)())(f))
#define EVT_HDAE_LYRIC_ALL_DRAW 0x1ca0008L
#define EVT_HDAE_DRAW_SYLLABLE 0x1ca0009L
extern char *__cdecl HDAE5000_StrCpy(char *, char *);
extern int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
struct Point { int x, y; };
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
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };
extern long HDAE5000_RAM_LyricBoxObj;
extern struct LyricEvent HDAE5000_RAM_LyricEvent;
union LyrLineU { unsigned char b[25]; struct LyrLine s; };
extern union LyrLineU ram_2304d8;
#define LYR_LEN(i) ram_2304d8.b[(i) + 16]
extern struct Point ram_230822;
extern char ram_23051e[];
extern unsigned char ram_230610[128];
extern char ram_230690[128];
extern char ram_23074c[10];
extern unsigned char ram_230760, ram_230764;
extern unsigned int ram_23076a, ram_230772;
extern int ram_230774[40];
extern unsigned char ram_2307ba[6];
extern int ram_23080e[39];
extern unsigned long ram_23080c;
extern unsigned long ram_230810;
extern unsigned int ram_230814, ram_230818;
extern unsigned char ram_230826;
extern char HDAE5000_Fmt_Fault_No_Lyrics_loaded_o[];
extern char HDAE5000_Fmt_i_i[], HDAE5000_Fmt_Chord_s[];
long HDAE5000_Lyrics_FillLines(int, unsigned int);
long HDAE5000_Lyrics_FindEvent(int, int, int, long);
void Lyr_PlayToPos_l(struct LyricPosEvt *pe, unsigned char redraw)
{
    long r;
    unsigned long t;
    int len;
    unsigned int n;
    int l;

    t = pe->pos * ram_230810;
    if (ram_23080c == t)
        return;
    ram_23080c = t;
    if (HDAE5000_RAM_LyricEvent.nexttick > ram_23080c)
        return;
    if (HDAE5000_RAM_LyricEvent.eot != 0)
        return;
    n = 0;
    do {
        r = HDAE5000_Lyrics_FindEvent(0x7c, 2, -2, ram_230814);
        if (HDAE5000_RAM_LyricEvent.eot == 1)
            return;
        if (r <= 0)
            goto fault;
        ram_230814 += r;
        n++;
        switch (HDAE5000_RAM_LyricEvent.type) {
        case 5:
            if (ram_230610[0] == 0x0d || ram_230610[0] == 0x0a) {
                ram_2304d8.s.col = 0;
                if (ram_2304d8.s.line >= 2)
                    goto scroll;
                ram_2304d8.s.line++;
                return;
            fault:
                HDAE5000_SPrintf((void *)ram_230690, HDAE5000_Fmt_Fault_No_Lyrics_loaded_o, r, ram_230772, n);
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 2L);
                return;
            scroll:
                r = HDAE5000_Lyrics_FillLines(1, ram_230818);
                ram_2304d8.s.hilite = 0;
                if (r > 0)
                    ram_230818 = r;
                if (redraw == 1)
                    CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                return;
            }
            l = HDAE5000_StrLen((char *)ram_230610);
            len = l;
            if (l > 39)
                return;
            HDAE5000_StrCpy((void *)ram_23051e, (char *)ram_230610);
            if (len + ram_2304d8.s.col > 39) {
                ram_2304d8.s.col = 0;
                if (ram_2304d8.s.line < 2)
                    ram_2304d8.s.line++;
                else {
                    r = HDAE5000_Lyrics_FillLines(1, ram_230818);
                    if (r > 0)
                        ram_230818 = r;
                    if (redraw == 1)
                        CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                }
            }
            ram_230822.x = ram_230774[LYR_LEN((int)ram_2304d8.s.line)] + ram_23080e[ram_2304d8.s.col];
            ram_230822.y = ram_2307ba[ram_2304d8.s.line];
            ram_2304d8.s.col += len;
            ram_2304d8.s.hilite = 1;
            if (redraw == 1)
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 0L);
            if (ram_2304d8.s.col == ram_230818) {
                if (ram_230826 != 0x0d || ram_230826 != 0x0a) {
                    ram_2304d8.s.col = 0;
                    if (ram_2304d8.s.line < 2)
                        ram_2304d8.s.line++;
                    else {
                        r = HDAE5000_Lyrics_FillLines(1, ram_230818);
                        if (r > 0)
                            ram_230818 = r;
                        if (redraw == 1)
                            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_LYRIC_ALL_DRAW, 0L);
                    }
                }
            }
            break;
        case 88:
            ram_230760 = ram_230610[0];
            if (ram_230610[1] == 1) {
                ram_230764 = 2;
                ram_23076a = 24;
            }
            if (ram_230610[1] == 2) {
                ram_230764 = 4;
                ram_23076a = 12;
            }
            if (ram_230610[1] == 3) {
                ram_230764 = 8;
                ram_23076a = 6;
            }
            if (ram_230610[1] == 4) {
                ram_230764 = 16;
                ram_23076a = 3;
            }
            HDAE5000_SPrintf((void *)ram_23074c, HDAE5000_Fmt_i_i, ram_230760, ram_230764);
            CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 4L);
            break;
        case 126:
            switch (ram_230610[0]) {
            case '0':
                HDAE5000_SPrintf((void *)ram_230690, HDAE5000_Fmt_Chord_s, &ram_230610[1]);
                CALLV(ROOT->SendEvent)(HDAE5000_RAM_LyricBoxObj, EVT_HDAE_DRAW_SYLLABLE, 2L);
            }
            break;
        }
    } while (HDAE5000_RAM_LyricEvent.nexttick <= ram_23080c && r > 0);
}
