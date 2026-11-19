/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hd_r78_lyricbox__lyricbox_r2b.c (2026-11-19-70-hd-r78-v201b)
   sha256 2f5117ca099fcb9d5aadd9420fb0345316d1b045c5f30125ff74c0e6b63dad3a (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: LyrBox_c=HDAE5000_LyricBoxProc */
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
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HIDE 0x1c00002L
#define EVT_DRAW 0x1c0000dL
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_TICKS 0x1ca0004L
#define EVT_HDAE_INIT_LYRIC_PARAM 0x1ca0003L
#define EVT_HDAE_BEAT_MESSAGE 0x1ca0005L
#define EVT_HDAE_INIT_LYRICS 0x1ca0007L
#define EVT_HDAE_LYRIC_ALL_DRAW 0x1ca0008L
#define EVT_HDAE_DRAW_SYLLABLE 0x1ca0009L
#define EVT_SW_IN 0x1c00007L
#define EVT_PAINT 0x1c0000bL
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
#define OBJ_Conductor 0x7f02f4L
#define OBJ_LoadLyricFD 0x7f0303L
#define OBJ_MeasureinLyric 0x7f0300L
#define OBJ_SongTitle 0x7f02f2L
#define OBJ_TimeSigInLyric 0x7f0301L
#define OBJ_bottom01 0x7f02f5L
#define OBJ_bottom08 0x7f02fcL
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
struct LyrView { char p0[22]; int a22; char p1[4]; int *flag; long l32; int a36; int a38; long l40; int a44; };
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };
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
struct LyrText {
    char syl[246];
    char chord[128];            /* 0x230610 */
    char info[128];             /* 0x230690 */
    char cond[36];              /* 0x230710 */
    char title[24];             /* 0x230734 */
    char tsig[10];              /* 0x23074c */
    char meas[10];              /* 0x230756 */
};
struct LyrTick { unsigned long tick; struct Point pos; };
extern char HDAE5000_RAM_LyricLines[6][35];
extern long HDAE5000_RAM_LyricBoxObj;
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
extern char HDAE5000_Str_Blank34[], HDAE5000_Str_Reset[], HDAE5000_Str_Load[], HDAE5000_Fmt_03i_i[];
void HDAE5000_Lyrics_ClearBuffer(void);
void HDAE5000_Lyrics_PlayToPosition(struct LyricPosEvt *, int);
long HDAE5000_Lyrics_ResetState(void);
long HDAE5000_Lyrics_ReadSongInfo(long);
long HDAE5000_Lyrics_FillLines(int, unsigned int);
long LyrBox_c(long obj, long ev, long p)
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
            CALLV(ROOT->DrawString)(&ram_22a088.box, &pt.x, (char *)HDAE5000_Str_Blank34, ram_22a088.v->l32,
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
