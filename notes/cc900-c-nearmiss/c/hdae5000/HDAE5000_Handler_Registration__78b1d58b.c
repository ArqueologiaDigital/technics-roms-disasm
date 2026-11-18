/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r54_misc_reg.c (2026-11-18-20-hd-r55)
   sha256 78b1d58be79c280acff91983a13fd5b0031d58252f3342f6e9e4988f2aebdf0c (tar-sha256); compiled at -Xr
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
#define CALLV(f) ((void (*)())(f))
#define NAKA_MAINFUNC_HDAETitleFunc 0x14a0000L
#define NAKA_CLASS_Function 0x1600001L
#define NAKA_CLASS_ApFunction 0x1600002L
#define NAKA_CLASS_MainFunction 0x1600003L
#define NAKA_CLASS_Class 0x1600004L
#define NAKA_CLASS_ResEvent 0x160000cL
#define NAKA_CLASS_ResMethod 0x160000dL
#define NAKA_CLASS_ResName 0x160000fL
#define NAKA_CLASS_Viewable 0x1600010L
#define OBJ_IV_HDDMENU 0x7f01eeL
struct ObjReg { long cls; void *proc; unsigned int count; void *table; };
extern unsigned int HDAE5000_RECORD_COUNT;
extern unsigned char HDAE5000_RECORD_TABLE[];
extern void *HDAE5000_UiObject_PtrTable[];
extern void *HDAE5000_UiObjectName_PtrTable[];
extern char HDAE5000_GFX_INIT_PARAMS[];
extern unsigned int ram_239822;
extern unsigned int ram_239870;
extern void *ram_23952a[];
extern void *ram_239642[];
extern void *ram_2397ea[];
extern void *ram_239824[];
extern void *ram_239872[];
extern void *ram_2398aa[];
extern void *ram_239fd2[];
extern void *ram_23a00e[];
void HDAE5000_Handler_Registration(void)
{
    struct ObjReg rec;

    rec.cls = NAKA_CLASS_Class;
    rec.proc = ROOT->ClassProc;
    rec.count = HDAE5000_RECORD_COUNT;
    rec.table = HDAE5000_RECORD_TABLE;
    CALLV(ROOT->RegisterObjectTable)(0x16a, (void *)&rec);
    rec.cls = NAKA_CLASS_ResEvent;
    rec.proc = ROOT->ResEventProc;
    rec.count = ram_239822;
    rec.table = ram_2397ea;
    CALLV(ROOT->RegisterObjectTable)(0x1ca, (void *)&rec);
    rec.cls = NAKA_CLASS_ResMethod;
    rec.proc = ROOT->ResMethodProc;
    rec.count = ram_239870;
    rec.table = ram_239824;
    CALLV(ROOT->RegisterObjectTable)(0x1ea, (void *)&rec);
    rec.cls = NAKA_CLASS_ApFunction;
    rec.proc = ROOT->ApFunctionProc;
    rec.count = 0x45;
    rec.table = ram_23952a;
    CALLV(ROOT->RegisterObjectTable)(0x12a, (void *)&rec);
    rec.cls = NAKA_CLASS_ApFunction;
    rec.proc = ROOT->ApFunctionProc;
    rec.count = 0x45;
    rec.table = ram_239642;
    CALLV(ROOT->RegisterObjectTable)(0x42a, (void *)&rec);
    rec.cls = NAKA_CLASS_Function;
    rec.proc = ROOT->FunctionProc;
    rec.count = 0x0d;
    rec.table = ram_239872;
    CALLV(ROOT->RegisterObjectTable)(0x10a, (void *)&rec);
    rec.cls = NAKA_CLASS_Function;
    rec.proc = ROOT->FunctionProc;
    rec.count = 0x0d;
    rec.table = ram_2398aa;
    CALLV(ROOT->RegisterObjectTable)(0x40a, (void *)&rec);
    rec.cls = NAKA_CLASS_MainFunction;
    rec.proc = ROOT->MainFunctionProc;
    rec.count = 0x0e;
    rec.table = ram_239fd2;
    CALLV(ROOT->RegisterObjectTable)(0x14a, (void *)&rec);
    rec.cls = NAKA_CLASS_MainFunction;
    rec.proc = ROOT->MainFunctionProc;
    rec.count = 0x0e;
    rec.table = ram_23a00e;
    CALLV(ROOT->RegisterObjectTable)(0x44a, (void *)&rec);
    rec.cls = NAKA_CLASS_Viewable;
    rec.proc = ROOT->ViewableProc;
    rec.count = 0x315;
    rec.table = HDAE5000_UiObject_PtrTable;
    CALLV(ROOT->RegisterObjectTable)(0x7f, (void *)&rec);
    rec.cls = NAKA_CLASS_ResName;
    rec.proc = ROOT->ResNameProc;
    rec.count = 0x315;
    rec.table = HDAE5000_UiObjectName_PtrTable;
    CALLV(ROOT->RegisterObjectTable)(0x37f, (void *)&rec);
    CALLV(ROOT->RegisterTitle)(0x7fL, NAKA_MAINFUNC_HDAETitleFunc, OBJ_IV_HDDMENU, (long)HDAE5000_GFX_INIT_PARAMS, 10);
}
