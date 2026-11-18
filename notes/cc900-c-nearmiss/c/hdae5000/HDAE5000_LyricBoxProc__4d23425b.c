/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r50_lybb.c (2026-11-18-13-hd-r52)
   sha256 4d23425b1acb26de6b51b73acd448686a0e3dae106e4bd8fa99b6aca3136f602 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
#define OBJ_Conductor 0x7f02f5L
#define OBJ_LoadLyricFD 0x7f0304L
#define OBJ_MeasureinLyric 0x7f0301L
#define OBJ_SongTitle 0x7f02f3L
#define OBJ_TimeSigInLyric 0x7f0302L
#define OBJ_bottom01 0x7f02f6L
#define OBJ_bottom08 0x7f02fdL
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
struct Box { int x1, y1, x2, y2; };
struct Point { int x, y; };
struct LyrView { char p0[22]; int a22; char p1[4]; int *flag; long l32; char p2[4]; long l40; int a44; };
struct LyricPosEvt { unsigned int sqbtof; unsigned int step; unsigned long pos; };
extern char HDAE5000_RAM_LyricLines[6][40];
extern long HDAE5000_RAM_LyricBoxObj;
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
long HDAE5000_LyricBoxProc(long obj, long ev, long p)
{
    struct Point pt;
    struct LyrView *v;
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
            int k;

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
                ram_230808[k] = (unsigned char)(k * 18 + ram_22a08c.y1) + 15;
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
