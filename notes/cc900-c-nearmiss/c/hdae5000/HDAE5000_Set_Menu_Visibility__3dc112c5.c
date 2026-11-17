/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r2_ma.c (2026-11-16-48-hd-r2b)
   sha256 3dc112c56ffc9fe0435ce604d056875001eec301be930b905b124ba34e7a14bf (tar-sha256); compiled at -Xr */
typedef void (*VFN)();
struct RootFns {
    VFN pad0[33];
    VFN UpdateScreen;
    VFN pad1[5];
    VFN DrawLine;
    VFN pad2[1];
    VFN DrawBox;
    VFN DrawFrame;
    VFN pad3[1];
    VFN MovePixels;
    VFN pad4[4];
    VFN DrawString;
    VFN pad5[5];
    VFN InheritedProc;
    VFN pad6[1];
    VFN RegisterObjectTable;
    VFN pad7[6];
    VFN SendEvent;
    VFN PostEvent;
    VFN pad8[7];
    VFN ApPostEvent;
    VFN pad9[5];
    VFN ResEventProc;
    VFN ResMethodProc;
    VFN pad10[1];
    VFN ResNameProc;
    VFN pad11[1];
    VFN GetCharHeight;
    VFN GetCharDescent;
    VFN GetCenteredDelta;
    VFN ConvertStrings;
    VFN pad12[2];
    VFN ClassProc;
    VFN pad13[54];
    VFN FunctionProc;
    VFN ApFunctionProc;
    VFN MainFunctionProc;
    VFN ApFuncCall;
    VFN MainFuncCall;
    VFN pad14[6];
    VFN RegisterTitle;
    VFN pad15[1];
    VFN GetTitleNow;
    VFN pad16[1];
    VFN ViewableProc;
    VFN pad17[4];
    VFN SetVisible;
    VFN pad18[11];
    VFN GetViewInstance;
    VFN pad19[3];
    VFN GetClientBox;
    VFN pad20[1];
    VFN DrawDesignBox;
    VFN pad21[57];
    VFN SetDialEnable;
    VFN SetDialUp;
    VFN SetDialDown;
    VFN pad22[16];
    VFN SetApTimer;
    VFN pad23[1];
    VFN KillApTimer;
    VFN pad24[4];
    VFN SetAutoInc;
    VFN pad25[55];
    VFN GetNamingWindowID;
    VFN pad26[9];
    VFN DeleteEvent;
    VFN SleepMainTask;
    VFN WakeUpMainTask;
};
struct ObjTab { void *fns; char rest[10]; };
struct NakaWs { char hdr[10]; struct ObjTab tab[0x10a]; };
extern struct NakaWs *HDAE5000_RAM_MainWorkspacePtr;
#define ROOT ((struct RootFns *)HDAE5000_RAM_MainWorkspacePtr->tab[0x100].fns)
#define OBJ_CP_FD_HDSWSEL 0x7f00dcL
#define OBJ_CP_FD_HDSWTO 0x7f00daL
#define OBJ_FLS_FILE_LOAD_SW_EDIT 0x7f013eL
#define OBJ_FLS_SELECT_SW_EDIT 0x7f00f9L
#define OBJ_HD_FILE_LOAD_SW_DEL 0x7f010aL
#define OBJ_HD_FILE_LOAD_SW_DELFILE 0x7f010dL
#define OBJ_HD_FILE_LOAD_SW_SAVE 0x7f0100L
#define OBJ_SELECT_DIR_SW_EDIT 0x7f002cL
#define OBJ_SW_HD_FORMAT 0x7f0080L
void HDAE5000_Set_Menu_Visibility(unsigned char hide)
{
    int v;
    if (hide == 0)
        v = 1;
    else
        v = 0;
    ROOT->SetVisible(OBJ_SELECT_DIR_SW_EDIT, v);
    ROOT->SetVisible(OBJ_HD_FILE_LOAD_SW_SAVE, v);
    ROOT->SetVisible(OBJ_HD_FILE_LOAD_SW_DEL, v);
    ROOT->SetVisible(OBJ_FLS_SELECT_SW_EDIT, v);
    ROOT->SetVisible(OBJ_FLS_FILE_LOAD_SW_EDIT, v);
    ROOT->SetVisible(OBJ_HD_FILE_LOAD_SW_DELFILE, v);
    ROOT->SetVisible(OBJ_CP_FD_HDSWTO, v);
    ROOT->SetVisible(OBJ_CP_FD_HDSWSEL, v);
    ROOT->SetVisible(OBJ_SW_HD_FORMAT, v);
}
