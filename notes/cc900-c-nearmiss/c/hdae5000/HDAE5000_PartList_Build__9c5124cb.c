/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r9_b1.c (2026-11-16-60-hd-r9a)
   sha256 9c5124cbd5cf79e4c3ccc38a7b92fb3d1028ef816bafde66d95304c3193bebd4 (tar-sha256); compiled at -Xr */
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
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_HDAE_SET_STR_ADR 0x1ea000aL
extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern char HDAE5000_RAM_PartListText[];
extern char HDAE5000_PartNames_Text[];
extern char HDAE5000_PartNames_BlankText[];
extern char HDAE5000_PartName_Blank[];
void HDAE5000_PartList_Build(long obj, unsigned int dir, unsigned int song, unsigned int mask)
{
    if (dir == 0xffff || song == 0xffff) {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
    } else {
        HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_Text, 0x7f);
        if (mask != 0xffff) {
            if (!(mask & 0x001)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[0], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x002)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[14], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x004)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[28], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x008)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[42], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x010)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[56], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x020)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[70], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x040)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[84], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x080)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[98], HDAE5000_PartName_Blank, 14);
            if (!(mask & 0x100)) HDAE5000_MemCopy(&HDAE5000_RAM_PartListText[112], HDAE5000_PartName_Blank, 14);
        } else {
            HDAE5000_MemCopy(HDAE5000_RAM_PartListText, HDAE5000_PartNames_BlankText, 0x7f);
        }
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, HDAE5000_RAM_PartListText);
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}
