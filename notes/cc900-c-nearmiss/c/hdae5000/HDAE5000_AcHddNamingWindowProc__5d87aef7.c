/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_naming_window.c (2026-11-19-14-hd-r61-ids-ports)
   sha256 5d87aef7424010650e156e08894326c22c4e6d7906d0c9dbe4b29415c7580757 (tar-sha256); compiled at -Xr
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
struct HamaFns {
    void *pad0[1];
    void *FDLoadSaveTest;
    void *GetMediaType;
    void *PreLswLoad;
    void *PostLswLoad;
    void *PreLswSave;
    void *PostLswSave;
    void *PrePmLoad;
    void *PostPmLoad;
    void *PrePmSave;
    void *PostPmSave;
    void *SeqLoadPre;
    void *SeqLoadPost;
    void *SeqSavePre;
    void *SeqSavePost;
    void *cmp_ld_mae;
    void *cmp_ld_ato;
    void *cmp_sv_mae;
    void *cmp_sv_ato;
    void *PreTmLoad;
    void *PostTmLoad;
    void *PreTmSave;
    void *PostTmSave;
    void *msp_ld_mae;
    void *msp_ld_ato;
    void *msp_sv_mae;
    void *msp_sv_ato;
    void *PreMidiLoad;
    void *PostMidiLoad;
    void *PreMidiSave;
    void *PostMidiSave;
    void *FlashWrite;
    void *GetResouceInfo;
    void *SetSepaOutMode;
    void *pad1[2];
    void *GetVolumeLabel;
    void *findfirst;
    void *findnext;
    void *findclose;
    void *fopen_ext;
    void *pad2[1];
    void *fread_ext;
    void *fclose_ext;
    void *rcm_ld_XAPR_j;
    void *rcm_sv_XAPR_j;
    void *rot_rdq_X;
    void *pad3[5];
    void *ref_sem_X;
    void *pad4[4];
    void *pdly_tim_X;
    void *PlayHalt;
    void *PlayStandBy;
    void *EditSwRefresh;
    void *pad5[3];
    void *GetAdr_sqbtof;
    void *GetAdr_sq_beadt;
    void *GetAdr_sqsrtc;
    void *pad6[2];
    void *sendCOMM;
    void *pad7[2];
    void *SwbtWr;
    void *pad8[2];
    void *SetGlobalError;
    void *malloc_X;
    void *free_X;
    void *ChangePalette;
    void *ChangeWall;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define HAMA ((struct HamaFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x109].fns)
#define CALLR(t, f) ((t (*)())(f))
#define CALLV(f) ((void (*)())(f))
#define EVT_SHOW 0x1c00001L
#define EVT_HIDE 0x1c00002L
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_PAINT 0x1c0000bL
#define EVT_REPAINT 0x1c0000cL
#define EVT_SELE_DRAW 0x1c0000eL
#define EVT_INDEXSW_UP 0x1c00017L
#define EVT_INDEXSW_DOWN 0x1c00018L
#define EVT_INDEXSW_UP_AIC 0x1c00019L
#define EVT_INDEXSW_DOWN_AIC 0x1c0001aL
#define EVT_I_AM_SELECTED 0x1c00029L
#define EVT_YOU_ARE_SELECTED 0x1c0002aL
#define EVT_GET_STRING 0x1e0003aL
#define EVT_SET_AP_FUNCTION 0x1e0007bL
#define EVT_GET_STRING_LENGTH 0x1e0007cL
#define EVT_SET_PAGE 0x1e0007fL
#define EVT_SET_CURSOR 0x1e00080L
#define EVT_SET_CHARA 0x1e00081L
#define EVT_GET_NAMING_MODE 0x1e00084L
#define EVT_SET_STRING 0x1e00086L
#define NAKA_APFUNC_NamingCheck 0x1200005L
#define OBJ_HddNamingABC 0x7f01b2L
#define OBJ_HddNamingCursorBox 0x7f01b1L
#define OBJ_HddNamingLabel 0x7f01b8L
#define OBJ_HddNamingSymbol 0x7f01b4L
#define OBJ_HddNamingabc 0x7f01b3L
extern char *__cdecl HDAE5000_StrCpy(char *, const char *);
extern unsigned int __cdecl HDAE5000_StrLen(unsigned char *);
extern unsigned char HDAE5000_RAM_NamingText[];
extern long HDAE5000_RAM_NamingApFunction;
extern unsigned int HDAE5000_RAM_NamingLength;
extern unsigned int HDAE5000_RAM_NamingCursor;
extern unsigned int ram_22a02a;
extern unsigned int ram_22a02c;
extern unsigned int HDAE5000_RAM_NamingSelChar;
extern unsigned int HDAE5000_RAM_NamingSelCharDrawn;
extern unsigned int ram_22a032;
extern unsigned char *HDAE5000_RAM_NamingFillCharPtr;
extern unsigned char *HDAE5000_TextPtrs_Blank1_Chr5F[];
extern char **HDAE5000_TablePtrs_AcHddNamingWindowProc[];
extern unsigned int HDAE5000_Str_Chr25_AcHddNamingWindowProc[];
extern char *HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526[];
extern char *HDAE5000_TextPtrs_Chr21_to_Chr7D[];
extern unsigned char HDAE5000_CType_Table[];
struct NBox { int x; int y; int x2; int y2; };
struct NPt { int x; int y; };
long HDAE5000_AcHddNamingWindowProc(long obj, long ev, long arg)
{
    unsigned int i;
    unsigned int lead;
    unsigned int trail;
    unsigned int half;
    unsigned char *tmp;
    char **tbl;
    struct NBox box;
    struct NBox rect;
    struct NPt pt;
    unsigned char buf[10];

    switch (ev) {
    case EVT_SHOW:
        if (arg == 0 || arg == 3 || arg == 5) {
            if (HDAE5000_RAM_NamingApFunction == 0)
                HDAE5000_RAM_NamingApFunction = NAKA_APFUNC_NamingCheck;
            HDAE5000_RAM_NamingCursor = 0;
            ram_22a02a = 0;
            HDAE5000_RAM_NamingLength = (unsigned int)CALLR(long, ROOT->ApFuncCall)(HDAE5000_RAM_NamingApFunction, EVT_GET_STRING_LENGTH, 0L);
            if (HDAE5000_RAM_NamingLength > 32)
                HDAE5000_RAM_NamingLength = 32;
            ram_22a032 = (unsigned int)CALLR(long, ROOT->ApFuncCall)(HDAE5000_RAM_NamingApFunction, EVT_GET_NAMING_MODE, 0L);
            HDAE5000_RAM_NamingFillCharPtr = HDAE5000_TextPtrs_Blank1_Chr5F[ram_22a032];
            if (ram_22a032 != 0) {
                CALLV(ROOT->SetVisible)(OBJ_HddNamingABC, 0);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingabc, 0);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingSymbol, 0);
            } else {
                CALLV(ROOT->SetVisible)(OBJ_HddNamingABC, 1);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingabc, 1);
                CALLV(ROOT->SetVisible)(OBJ_HddNamingSymbol, 1);
            }
            for (i = 0; i < HDAE5000_RAM_NamingLength; i++)
                HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
            HDAE5000_RAM_NamingText[i] = 0;
            CALLV(ROOT->ApFuncCall)(HDAE5000_RAM_NamingApFunction, EVT_GET_STRING, (long)HDAE5000_RAM_NamingText);
        }
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SetDialUp)(obj, EVT_INDEXSW_UP, 5L);
        CALLV(ROOT->SetDialDown)(obj, EVT_INDEXSW_DOWN, 3L);
        CALLV(ROOT->SetDialEnable)(1);
        return 0;
    case EVT_PAINT:
    case EVT_REPAINT:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        ram_22a02c = 0xffff;
        HDAE5000_RAM_NamingSelCharDrawn = 0xffff;
        CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
        return 0;
    case EVT_HIDE:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        return 0;
    case EVT_SELE_DRAW:
        HDAE5000_RAM_NamingSelChar = arg;
        if (HDAE5000_RAM_NamingSelCharDrawn != HDAE5000_RAM_NamingSelChar) {
            CALLV(ROOT->GetClientBox)(obj, (long)&box);
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            if (HDAE5000_RAM_NamingSelCharDrawn != 0xffff) {
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelCharDrawn], (long)buf);
                rect.y = box.y + 10 + HDAE5000_RAM_NamingSelCharDrawn / 13 * 24;
                rect.x = box.x + 14 + HDAE5000_RAM_NamingSelCharDrawn % 13 * 16 - 1;
                rect.x2 = rect.x + HDAE5000_StrLen(buf) * 8 + 2;
                rect.y2 = rect.y + 17;
                CALLV(ROOT->DrawFrame)(&rect, 0xf5);
            }
            CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
            rect.y = box.y + 10 + HDAE5000_RAM_NamingSelChar / 13 * 24;
            rect.x = box.x + 14 + HDAE5000_RAM_NamingSelChar % 13 * 16 - 1;
            rect.x2 = rect.x + HDAE5000_StrLen(buf) * 8 + 2;
            rect.y2 = rect.y + 17;
            CALLV(ROOT->DrawFrame)(&rect, 0xf2);
            HDAE5000_RAM_NamingSelCharDrawn = HDAE5000_RAM_NamingSelChar;
        }
        return 0;
    case EVT_PARA_DRAW:
        if (ram_22a02c != ram_22a02a) {
            HDAE5000_RAM_NamingSelCharDrawn = 0xffff;
            CALLV(ROOT->GetClientBox)(obj, (long)&box);
            CALLV(ROOT->DrawBox)(&box, 0xf5);
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            for (i = 0; i <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]; i++) {
                pt.x = box.x + 14 + i % 13 * 16;
                pt.y = box.y + 10 + i / 13 * 24;
                CALLV(ROOT->DrawString)((long)&box, (long)&pt, tbl[i], 0L, 0xff, 0xf7);
            }
            ram_22a02c = ram_22a02a;
        }
        return 0;
    case EVT_INDEXSW_UP_AIC:
    case EVT_INDEXSW_UP:
    case EVT_INDEXSW_DOWN_AIC:
    case EVT_INDEXSW_DOWN:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        switch ((unsigned long)arg) {
        case 1:     /* _OnPositionLeft */
            if (HDAE5000_RAM_NamingCursor != 0) {
                HDAE5000_RAM_NamingCursor--;
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 2:     /* _OnPositionRight */
            if (HDAE5000_RAM_NamingCursor + 1 < HDAE5000_RAM_NamingLength) {
                HDAE5000_RAM_NamingCursor++;
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 3:     /* _OnPrevCharacter */
            if (HDAE5000_RAM_NamingSelChar != 0) {
                tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                HDAE5000_RAM_NamingSelChar--;
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 4:     /* _OnCharacterRowUpDown */
            switch (ev) {
            case EVT_INDEXSW_UP_AIC:
            case EVT_INDEXSW_UP:
                if (HDAE5000_RAM_NamingSelChar >= 13) {
                    HDAE5000_RAM_NamingSelChar -= 13;
                    tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                    CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                    HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                    CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                    CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                }
                break;
            case EVT_INDEXSW_DOWN_AIC:
            case EVT_INDEXSW_DOWN:
                tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                if (HDAE5000_RAM_NamingSelChar + 12 <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]
                    && (buf[0] == 'Z' || buf[0] == 'z'))
                    HDAE5000_RAM_NamingSelChar--;
                if (HDAE5000_RAM_NamingSelChar + 13 <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]) {
                    HDAE5000_RAM_NamingSelChar += 13;
                    tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
                    CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                    if (buf[0] == 'S' && buf[1] == 'P')
                        HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = *HDAE5000_RAM_NamingFillCharPtr;
                    else
                        HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                    CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                    CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                    CALLV(ROOT->SetAutoInc)(obj, ev, arg);
                }
                break;
            }
            break;
        case 5:     /* _OnNextCharacter */
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            if (HDAE5000_RAM_NamingSelChar + 1 <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a]) {
                HDAE5000_RAM_NamingSelChar++;
                CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
                if (buf[0] == 'S' && buf[1] == 'P')
                    HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = *HDAE5000_RAM_NamingFillCharPtr;
                else
                    HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = buf[0];
                CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
                CALLV(ROOT->SetAutoInc)(obj, ev, arg);
            }
            break;
        case 6:     /* _OnInsert */
            for (i = HDAE5000_RAM_NamingLength - 1; i > HDAE5000_RAM_NamingCursor; i--)
                HDAE5000_RAM_NamingText[i] = HDAE5000_RAM_NamingText[i - 1];
            HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = *HDAE5000_RAM_NamingFillCharPtr;
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
            CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
            break;
        case 7:     /* _OnDelete */
            for (i = HDAE5000_RAM_NamingCursor; i < HDAE5000_RAM_NamingLength; i++)
                HDAE5000_RAM_NamingText[i] = HDAE5000_RAM_NamingText[i + 1];
            HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingLength - 1] = *HDAE5000_RAM_NamingFillCharPtr;
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
            CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
            break;
        case 8:     /* _OnCenterName */
            lead = 0;
            for (i = 0; i < HDAE5000_RAM_NamingLength; i++) {
                if (HDAE5000_RAM_NamingText[i] != *HDAE5000_RAM_NamingFillCharPtr)
                    break;
                lead++;
            }
            if (lead != HDAE5000_RAM_NamingLength) {
                trail = 0;
                for (i = 0; i < HDAE5000_RAM_NamingLength; i++) {
                    if (HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingLength - i - 1] != *HDAE5000_RAM_NamingFillCharPtr)
                        break;
                    trail++;
                }
                half = lead;
                half += trail;
                half >>= 1;
                tmp = (unsigned char *)CALLR(void *, HAMA->malloc_X)((unsigned long)(HDAE5000_RAM_NamingLength + 1));
                HDAE5000_StrCpy((char *)tmp, (char *)&HDAE5000_RAM_NamingText[lead]);
                tmp[HDAE5000_RAM_NamingLength - lead - trail] = 0;
                HDAE5000_StrCpy((char *)&HDAE5000_RAM_NamingText[half], (char *)tmp);
                CALLV(HAMA->free_X)(tmp);
                for (i = 0; i < half; i++)
                    HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
                for (i = HDAE5000_RAM_NamingLength - (lead + trail - half); i < HDAE5000_RAM_NamingLength; i++)
                    HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
                CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
            }
            break;
        case 9:     /* _OnClear */
            for (i = 0; i < HDAE5000_RAM_NamingLength; i++)
                HDAE5000_RAM_NamingText[i] = *HDAE5000_RAM_NamingFillCharPtr;
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_SET_CURSOR, 0L);
            CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
            CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, 0L);
            break;
        }
        return 0;
    case EVT_SET_STRING:
        HDAE5000_StrCpy((char *)HDAE5000_RAM_NamingText, (char *)arg);
        CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, 0L);
        return 0;
    case EVT_GET_STRING:
        HDAE5000_StrCpy((char *)arg, (char *)HDAE5000_RAM_NamingText);
        return 0;
    case EVT_SET_AP_FUNCTION:
        HDAE5000_RAM_NamingApFunction = arg;
        return 0;
    case EVT_SET_PAGE:
        ram_22a02a = arg;
        if (ram_22a032 == 0)
            CALLV(ROOT->SendEvent)(-1L, EVT_YOU_ARE_SELECTED, (unsigned long)(unsigned int)arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (unsigned long)ram_22a02a);
        CALLV(ROOT->SendEvent)(OBJ_HddNamingLabel, EVT_PARA_DRAW, HDAE5000_TextPtrs_ABC123_Abc123_Chr202123242526[ram_22a02a]);
        return 0;
    case EVT_SET_CURSOR:
        HDAE5000_RAM_NamingCursor = arg;
        CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
        CALLV(ROOT->SendEvent)(OBJ_HddNamingCursorBox, EVT_PARA_DRAW, (long)HDAE5000_RAM_NamingText);
        if (HDAE5000_CType_Table[HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]] & 1) {
            ram_22a02a = 0;
            HDAE5000_RAM_NamingSelChar = (unsigned char)(HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] - 'A');
        } else if (HDAE5000_CType_Table[HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]] & 2) {
            ram_22a02a = 1;
            HDAE5000_RAM_NamingSelChar = (unsigned char)(HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] - 'a');
        } else if (HDAE5000_CType_Table[HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]] & 4) {
            if (ram_22a02a == 2)
                ram_22a02a = 0;
            HDAE5000_RAM_NamingSelChar = (unsigned char)(HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] - 0x15);
        } else if (HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] == ' ') {
            if (ram_22a032 == 0) {
                if (ram_22a02a == 2)
                    ram_22a02a = 0;
                HDAE5000_RAM_NamingSelChar = 37;
            }
        } else if (HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] == '_') {
            if (ram_22a02a == 2)
                ram_22a02a = 0;
            HDAE5000_RAM_NamingSelChar = 26;
        } else {
            tbl = HDAE5000_TextPtrs_Chr21_to_Chr7D;
            for (i = 0; i <= HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + 2]; i++) {
                CALLV(ROOT->ConvertStrings)(tbl[i], (long)buf);
                if (buf[0] == HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor]) {
                    ram_22a02a = 2;
                    HDAE5000_RAM_NamingSelChar = i;
                }
            }
        }
        CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, (unsigned long)ram_22a02a);
        CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
        return 0;
    case EVT_SET_CHARA:
        HDAE5000_RAM_NamingText[HDAE5000_RAM_NamingCursor] = arg;
        CALLV(ROOT->SendEvent)(obj, EVT_SET_CURSOR, (unsigned long)HDAE5000_RAM_NamingCursor);
        return 0;
    case EVT_I_AM_SELECTED:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        if ((unsigned int)(((unsigned long)arg >> 16) & 0xffff) == 0) {
            CALLV(ROOT->SendEvent)(obj, EVT_SET_PAGE, (unsigned long)(unsigned int)arg);
            if (HDAE5000_RAM_NamingSelChar > HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a])
                HDAE5000_RAM_NamingSelChar = HDAE5000_Str_Chr25_AcHddNamingWindowProc[ram_22a032 * 3 + ram_22a02a];
            tbl = HDAE5000_TablePtrs_AcHddNamingWindowProc[ram_22a02a];
            CALLV(ROOT->ConvertStrings)(tbl[HDAE5000_RAM_NamingSelChar], (long)buf);
            if (buf[0] == 'S' && buf[1] == 'P')
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CHARA, (unsigned long)*HDAE5000_RAM_NamingFillCharPtr);
            else
                CALLV(ROOT->SendEvent)(obj, EVT_SET_CHARA, (unsigned long)buf[0]);
            CALLV(ROOT->SendEvent)(obj, EVT_SELE_DRAW, (unsigned long)HDAE5000_RAM_NamingSelChar);
        }
        return 0;
    default:
        return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
    }
}
