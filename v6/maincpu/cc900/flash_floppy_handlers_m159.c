/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/




unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}

/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_InitExtMemAddrs Flash_StoreBaseAndInitAccPatch Flash_WriteBackSlotTable NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store */
extern long __near RHYTHM_PATTERN_BUF_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_DST_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern unsigned char __near ram_34f8;
extern unsigned int __near ram_73a[];
extern unsigned char MSP_Default_ChannelMap[][3];
extern unsigned char MSP_Default_GroupIndexPad[];
extern void Flash_InitExtMemAddrs(void);
extern void DualVoice_ScanAllColumns(int);
extern void DualVoice_ScanAllColumnsAlt(int);
extern unsigned char NoteEvent_Store(int);
extern void NoteEventBuffer_CopyToSlot(int);
extern void AccPatch_CountSlotsAlt(void);
extern void AccPatch_InitFromSlotIndex(void);
extern void DualVoice_ParamLoadDone(void);
extern void Flash_StoreBaseAndInitAccPatch(void);
extern void NoteEventBuffer_Store(int);
extern void Flash_WriteBackSlotTable(void);
extern unsigned char DualVoice_LoadAndScan(unsigned char a, unsigned char c, long de);

unsigned char DualVoice_LoadAndScan(unsigned char a, unsigned char c, long de)
{
    unsigned char ret, v, idx, found;
    unsigned char i;
    ret = 0;
    found = 0;
    Flash_InitExtMemAddrs();
    RHYTHM_PATTERN_BUF_PTR = de;
    if (a >= 10) goto done;
    DualVoice_ScanAllColumns(a);
    DualVoice_ScanAllColumnsAlt(c);
    v = NoteEvent_Store(c);
    NoteEventBuffer_CopyToSlot(v);
    AccPatch_CountSlotsAlt();
    idx = MSP_Default_GroupIndexPad[c];
    STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
    i = 0;
    do {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][idx];
        AccPatch_InitFromSlotIndex();
    } while (++i < 10);
    STYLE_SRC_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
    STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
    ram_34f8 &= ~1;
    i = 0;
    do {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][a];
        STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i][idx];
        DualVoice_ParamLoadDone();
        if ((unsigned int)ram_34f8 & 1) {
            found = 1;
            break;
setret:
            ret = 1;
done:
            return ret;
        }
    } while (++i < 10);
    if (found != 0) goto setret;
    Flash_StoreBaseAndInitAccPatch();
    NoteEventBuffer_Store(v);
    if (ram_73a[0] == 0xffff && ram_73a[1] == 0xffff) goto done;
    Flash_WriteBackSlotTable();
    goto done;
}

#define NAKA_APFUNC_DefaultFunction        0x1200000L
#define NAKA_CLASS_ApFunction              0x1600002L
#define NAKA_CLASS_Class                   0x1600004L
#define NAKA_CLASS_Function                0x1600001L
#define NAKA_CLASS_MainFunction            0x1600003L
#define NAKA_CLASS_ResEvent                0x160000cL
#define NAKA_CLASS_ResMethod               0x160000dL
#define NAKA_CLASS_ResName                 0x160000fL
#define NAKA_CLASS_Viewable                0x1600010L
#define NAKA_VIEW_ftdemo01                 0xfd0000L
struct objreg { long cls; void *proc; int count; void *base; };
extern void RegisterObjectTable(unsigned int, struct objreg *);
extern void RegisterTitle(long id, long func, long view, int b, char *name);
extern long ApFunctionProc(long, long, long);
extern long ClassProc(long, long, long);
extern long FunctionProc(long, long, long);
extern long MainFunctionProc(long, long, long);
extern long ResEventProc(long, long, long);
extern long ResMethodProc(long, long, long);
extern long ResNameProc(long, long, long);
extern long ViewableProc(long, long, long);
extern int Naka_ClassCount_16B;
extern int Naka_ResEventCount_1CB;
extern int Naka_ResMethodCount_1EB;
extern char InitializeNaka_Str_TT_FDMSP[];
extern char NAKA_UIObjectTable[];
extern char Naka_ApFuncNameTable_42B[];
extern char Naka_ApFuncTable_12B[];
extern char Naka_MainFunctionTable_14B[];
extern char Naka_MainFunctionTable_44B[];
extern char Naka_ResNameTable_3FD[];
extern char ToneGen_ParamTable_0x53D[];
extern char ToneGen_ParamTable_0x557[];
extern char ToneGen_ParamTable_0x55D[];
extern char ToneGen_ParamTable_0x563[];
extern char ToneGen_ParamTable_0x567[];
extern void InitializeNaka(void);
#define NAKA_MAINFUNC_CmEsyTtlFunc         0x1440007L
#define NAKA_MAINFUNC_CmpBkslTtlFunc       0x1440003L
#define NAKA_MAINFUNC_CmpBksl_STtlFunc     0x1440004L
#define NAKA_MAINFUNC_CmpMenuTtlFunc       0x1440005L
#define NAKA_MAINFUNC_CmpModeFunc          0x1440000L
#define NAKA_MAINFUNC_CmpNcpTtlFunc        0x1440006L
#define NAKA_MAINFUNC_CmpRealTtlFunc       0x1440002L
#define NAKA_MAINFUNC_CmpSetTtlFunc        0x1440001L
#define NAKA_MAINFUNC_CmpStepTitleFunc     0x1440019L
#define NAKA_MAINFUNC_CstmCpTtlFunc        0x1440009L
#define NAKA_MAINFUNC_MspBkslTtlFunc       0x1440011L
#define NAKA_MAINFUNC_MspMenuTtlFunc       0x1440012L
#define NAKA_MAINFUNC_MspNameTtlFunc       0x1440013L
#define NAKA_MAINFUNC_MspRecTtlFunc        0x1440015L
#define NAKA_MAINFUNC_S2cTtlFunc           0x1440008L
#define NAKA_MAINFUNC_SndArgModeFunc       0x1440016L
#define NAKA_MAINFUNC_SndArgTtlFunc        0x1440017L
#define NAKA_MAINFUNC_StylCnvCnvtTtlFunc   0x144001fL
#define NAKA_MAINFUNC_StylCnvContTtlFunc   0x1440021L
#define NAKA_MAINFUNC_StylCnvModlTtlFunc   0x144001eL
#define NAKA_MAINFUNC_StylCnvSelTtlFunc    0x1440020L
#define NAKA_MAINFUNC_StylCnvStorTtlFunc   0x1440022L
#define NAKA_MAINFUNC_StylCnvTxtTtlFunc    0x144001dL
#define NAKA_MAINFUNC_StylCnvWaitTtlFunc   0x144001cL
#define NAKA_VIEW_ApcSelScreen             0xed0000L
#define TITLE_CMMENU                       0x1a000b0L
#define TITLE_MSPMENU                      0x1a000caL
#define TITLE_MSPREC                       0x1a000c9L
#define TITLE_SNDARG                       0x1a000dcL
extern void RegisterMode(long id, long func, long a, int b, char *name);
extern int Suna_ClassCount_164;
extern int Suna_ResEventCount_1C4;
extern int Suna_ResMethodCount_1E4;
extern char Composer_CallbackNameTable[];
extern char Composer_FunctionTable[];
extern char InitializeSuna_Str_MD_CMP[];
extern char InitializeSuna_Str_MD_MSP[];
extern char InitializeSuna_Str_MD_MSP_REC[];
extern char InitializeSuna_Str_MD_SND_ARG[];
extern char InitializeSuna_Str_TT_APCSEL[];
extern char InitializeSuna_Str_TT_CMBAL[];
extern char InitializeSuna_Str_TT_CMBEND[];
extern char InitializeSuna_Str_TT_CMBKSL[];
extern char InitializeSuna_Str_TT_CMBKSL_S[];
extern char InitializeSuna_Str_TT_CMCSTMCP[];
extern char InitializeSuna_Str_TT_CMEASY[];
extern char InitializeSuna_Str_TT_CMMENU[];
extern char InitializeSuna_Str_TT_CMMODE[];
extern char InitializeSuna_Str_TT_CMNAME[];
extern char InitializeSuna_Str_TT_CMPNCP[];
extern char InitializeSuna_Str_TT_CMREAL[];
extern char InitializeSuna_Str_TT_CMSEQCP[];
extern char InitializeSuna_Str_TT_CMSET[];
extern char InitializeSuna_Str_TT_CMSTEP[];
extern char InitializeSuna_Str_TT_MSPBKSL[];
extern char InitializeSuna_Str_TT_MSPGROUP[];
extern char InitializeSuna_Str_TT_MSPMENU[];
extern char InitializeSuna_Str_TT_MSPNAME[];
extern char InitializeSuna_Str_TT_MSPREC[];
extern char InitializeSuna_Str_TT_SNDARG[];
extern char InitializeSuna_Str_TT_STYLCNVCNVT[];
extern char InitializeSuna_Str_TT_STYLCNVCONT[];
extern char InitializeSuna_Str_TT_STYLCNVMODL[];
extern char InitializeSuna_Str_TT_STYLCNVSEL[];
extern char InitializeSuna_Str_TT_STYLCNVSTOR[];
extern char InitializeSuna_Str_TT_STYLCNVTXT[];
extern char InitializeSuna_Str_TT_STYLCNVWAIT[];
extern char NakaMethodTable_PtrsStart[];
extern char Naka_Accomp10_Screens[];
extern char Naka_Accomp11_Screens[];
extern char Naka_Accomp12_Screens[];
extern char Naka_Accomp13_Screens[];
extern char Naka_Accomp14_Screens[];
extern char Naka_Accomp7_Screens[];
extern char Naka_Accomp9_Screens[];
extern char Naka_CmSetP1Grid_Screens[];
extern char Naka_CmpMem_Screens[];
extern char Naka_CmpMenu_Screens[];
extern char Naka_EasyComposer2_Screens[];
extern char Naka_EasyComposer_Screens[];
extern char Naka_ExpandMode_Screens[];
extern char Naka_ModeSelect_Screens[];
extern char Naka_NamingMem_Screens[];
extern char Naka_SeqToComposer_Screens[];
extern char Naka_StylCnvTxt_Screens[];
extern char Naka_StylCnvVer_Screens[];
extern char Naka_StylCnvWait_Screens[];
extern char PtrTbl_ApcSelScreenStrs[];
extern char PtrTbl_BendScreenStrs[];
extern char PtrTbl_CmpNcpScreenStrs[];
extern char PtrTbl_CstmCpScreenStrs[];
extern char PtrTbl_EasyCompScreenStrs[];
extern char PtrTbl_FuncNameStrs[];
extern char PtrTbl_MspBkslScreenStrs[];
extern char PtrTbl_MspMenuScreenStrs[];
extern char PtrTbl_MspReGrpScreenStrs[];
extern char PtrTbl_S2cScreenStrs[];
extern char PtrTbl_SndArgrScreenStrs[];
extern char Suna_ClassTable_164[];
extern char Suna_FunctionTable_104[];
extern char Suna_FunctionTable_404[];
extern char Suna_MainFunctionTable_144[];
extern char Suna_ResEventTable_1C4[];
extern char Suna_ResNameTable_313[];
extern char Suna_ResNameTable_314[];
extern char Suna_ResNameTable_316[];
extern char Suna_ResNameTable_3B0[];
extern char Suna_ResNameTable_3B2[];
extern char Suna_ResNameTable_3B3[];
extern char Suna_ResNameTable_3B6[];
extern char Suna_ResNameTable_3BD[];
extern char Suna_ResNameTable_3C9[];
extern char Suna_ResNameTable_3CB[];
extern char Suna_ViewableTable_010[];
extern char Suna_ViewableTable_011[];
extern char Suna_ViewableTable_012[];
extern char Suna_ViewableTable_013[];
extern char Suna_ViewableTable_014[];
extern char Suna_ViewableTable_015[];
extern char Suna_ViewableTable_016[];
extern char Suna_ViewableTable_0B0[];
extern char Suna_ViewableTable_0B1[];
extern char Suna_ViewableTable_0B2[];
extern char Suna_ViewableTable_0B3[];
extern char Suna_ViewableTable_0B4[];
extern char Suna_ViewableTable_0B5[];
extern char Suna_ViewableTable_0B6[];
extern char Suna_ViewableTable_0B7[];
extern char Suna_ViewableTable_0B8[];
extern char Suna_ViewableTable_C9[];
extern void InitializeSuna(void);

void InitializeNaka(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = Naka_ClassCount_16B;
	reg.base = ToneGen_ParamTable_0x53D;
	RegisterObjectTable(0x16b, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = Naka_ResEventCount_1CB;
	reg.base = ToneGen_ParamTable_0x557;
	RegisterObjectTable(0x1cb, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = Naka_ResMethodCount_1EB;
	reg.base = ToneGen_ParamTable_0x55D;
	RegisterObjectTable(0x1eb, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x12;
	reg.base = Naka_ApFuncTable_12B;
	RegisterObjectTable(0x12b, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x12;
	reg.base = Naka_ApFuncNameTable_42B;
	RegisterObjectTable(0x42b, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x0;
	reg.base = ToneGen_ParamTable_0x563;
	RegisterObjectTable(0x10b, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x0;
	reg.base = ToneGen_ParamTable_0x567;
	RegisterObjectTable(0x40b, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x0;
	reg.base = Naka_MainFunctionTable_14B;
	RegisterObjectTable(0x14b, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x0;
	reg.base = Naka_MainFunctionTable_44B;
	RegisterObjectTable(0x44b, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1de;
	reg.base = NAKA_UIObjectTable;
	RegisterObjectTable(0xfd, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1de;
	reg.base = Naka_ResNameTable_3FD;
	RegisterObjectTable(0x3fd, &reg);
	RegisterTitle(0xfd, NAKA_APFUNC_DefaultFunction, NAKA_VIEW_ftdemo01, 0xb, InitializeNaka_Str_TT_FDMSP);
}
void InitializeSuna(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = Suna_ClassCount_164;
	reg.base = Suna_ClassTable_164;
	RegisterObjectTable(0x164, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = Suna_ResEventCount_1C4;
	reg.base = Suna_ResEventTable_1C4;
	RegisterObjectTable(0x1c4, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = Suna_ResMethodCount_1E4;
	reg.base = NakaMethodTable_PtrsStart;
	RegisterObjectTable(0x1e4, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x49;
	reg.base = Composer_FunctionTable;
	RegisterObjectTable(0x124, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x49;
	reg.base = Composer_CallbackNameTable;
	RegisterObjectTable(0x424, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x1;
	reg.base = Suna_FunctionTable_104;
	RegisterObjectTable(0x104, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x1;
	reg.base = Suna_FunctionTable_404;
	RegisterObjectTable(0x404, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x24;
	reg.base = Suna_MainFunctionTable_144;
	RegisterObjectTable(0x144, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x24;
	reg.base = PtrTbl_FuncNameStrs;
	RegisterObjectTable(0x444, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x3;
	reg.base = Suna_ViewableTable_010;
	RegisterObjectTable(0x10, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x3;
	reg.base = Naka_Accomp14_Screens;
	RegisterObjectTable(0x310, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x8;
	reg.base = Suna_ViewableTable_011;
	RegisterObjectTable(0x11, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x8;
	reg.base = Naka_StylCnvWait_Screens;
	RegisterObjectTable(0x311, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x7;
	reg.base = Suna_ViewableTable_012;
	RegisterObjectTable(0x12, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x7;
	reg.base = Naka_StylCnvVer_Screens;
	RegisterObjectTable(0x312, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x4;
	reg.base = Suna_ViewableTable_013;
	RegisterObjectTable(0x13, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x4;
	reg.base = Suna_ResNameTable_313;
	RegisterObjectTable(0x313, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x4;
	reg.base = Suna_ViewableTable_014;
	RegisterObjectTable(0x14, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x4;
	reg.base = Suna_ResNameTable_314;
	RegisterObjectTable(0x314, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x8;
	reg.base = Suna_ViewableTable_015;
	RegisterObjectTable(0x15, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x8;
	reg.base = Naka_StylCnvTxt_Screens;
	RegisterObjectTable(0x315, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x7;
	reg.base = Suna_ViewableTable_016;
	RegisterObjectTable(0x16, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x7;
	reg.base = Suna_ResNameTable_316;
	RegisterObjectTable(0x316, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x12;
	reg.base = Suna_ViewableTable_0B0;
	RegisterObjectTable(0xb0, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x12;
	reg.base = Suna_ResNameTable_3B0;
	RegisterObjectTable(0x3b0, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xc;
	reg.base = Suna_ViewableTable_0B1;
	RegisterObjectTable(0xb1, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xc;
	reg.base = Naka_CmpMenu_Screens;
	RegisterObjectTable(0x3b1, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x16;
	reg.base = Suna_ViewableTable_0B2;
	RegisterObjectTable(0xb2, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x16;
	reg.base = Suna_ResNameTable_3B2;
	RegisterObjectTable(0x3b2, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x5;
	reg.base = Suna_ViewableTable_0B3;
	RegisterObjectTable(0xb3, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x5;
	reg.base = Suna_ResNameTable_3B3;
	RegisterObjectTable(0x3b3, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x12;
	reg.base = Suna_ViewableTable_0B4;
	RegisterObjectTable(0xb4, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x12;
	reg.base = Naka_NamingMem_Screens;
	RegisterObjectTable(0x3b4, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1f;
	reg.base = Suna_ViewableTable_0B5;
	RegisterObjectTable(0xb5, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1f;
	reg.base = Naka_CmSetP1Grid_Screens;
	RegisterObjectTable(0x3b5, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Suna_ViewableTable_0B6;
	RegisterObjectTable(0xb6, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Suna_ResNameTable_3B6;
	RegisterObjectTable(0x3b6, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x6;
	reg.base = Suna_ViewableTable_0B7;
	RegisterObjectTable(0xb7, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x6;
	reg.base = Naka_CmpMem_Screens;
	RegisterObjectTable(0x3b7, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x21;
	reg.base = Suna_ViewableTable_0B8;
	RegisterObjectTable(0xb8, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x21;
	reg.base = PtrTbl_CmpNcpScreenStrs;
	RegisterObjectTable(0x3b8, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x25;
	reg.base = Naka_SeqToComposer_Screens;
	RegisterObjectTable(0xb9, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x25;
	reg.base = PtrTbl_S2cScreenStrs;
	RegisterObjectTable(0x3b9, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xe;
	reg.base = Naka_EasyComposer_Screens;
	RegisterObjectTable(0xba, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xe;
	reg.base = PtrTbl_EasyCompScreenStrs;
	RegisterObjectTable(0x3ba, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x4;
	reg.base = Naka_EasyComposer2_Screens;
	RegisterObjectTable(0xbb, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x4;
	reg.base = PtrTbl_BendScreenStrs;
	RegisterObjectTable(0x3bb, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xb;
	reg.base = Naka_ModeSelect_Screens;
	RegisterObjectTable(0xbd, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xb;
	reg.base = Suna_ResNameTable_3BD;
	RegisterObjectTable(0x3bd, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x21;
	reg.base = Naka_ExpandMode_Screens;
	RegisterObjectTable(0xbe, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x21;
	reg.base = PtrTbl_CstmCpScreenStrs;
	RegisterObjectTable(0x3be, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1b;
	reg.base = Naka_Accomp7_Screens;
	RegisterObjectTable(0xc8, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1b;
	reg.base = PtrTbl_MspBkslScreenStrs;
	RegisterObjectTable(0x3c8, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x10;
	reg.base = Suna_ViewableTable_C9;
	RegisterObjectTable(0xc9, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x10;
	reg.base = Suna_ResNameTable_3C9;
	RegisterObjectTable(0x3c9, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x6;
	reg.base = Naka_Accomp9_Screens;
	RegisterObjectTable(0xca, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x6;
	reg.base = PtrTbl_MspMenuScreenStrs;
	RegisterObjectTable(0x3ca, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x4;
	reg.base = Naka_Accomp10_Screens;
	RegisterObjectTable(0xcb, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x4;
	reg.base = Suna_ResNameTable_3CB;
	RegisterObjectTable(0x3cb, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x9;
	reg.base = Naka_Accomp11_Screens;
	RegisterObjectTable(0xcc, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x9;
	reg.base = PtrTbl_MspReGrpScreenStrs;
	RegisterObjectTable(0x3cc, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x8;
	reg.base = Naka_Accomp12_Screens;
	RegisterObjectTable(0xdc, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x8;
	reg.base = PtrTbl_SndArgrScreenStrs;
	RegisterObjectTable(0x3dc, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x6;
	reg.base = Naka_Accomp13_Screens;
	RegisterObjectTable(0xed, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x6;
	reg.base = PtrTbl_ApcSelScreenStrs;
	RegisterObjectTable(0x3ed, &reg);
	RegisterMode(0xe, NAKA_MAINFUNC_CmpModeFunc, TITLE_CMMENU, 0x4, InitializeSuna_Str_MD_CMP);
	RegisterMode(0xf, NAKA_APFUNC_DefaultFunction, TITLE_MSPMENU, 0x4, InitializeSuna_Str_MD_MSP);
	RegisterMode(0x10, NAKA_APFUNC_DefaultFunction, TITLE_MSPREC, 0x4, InitializeSuna_Str_MD_MSP_REC);
	RegisterMode(0x11, NAKA_MAINFUNC_SndArgModeFunc, TITLE_SNDARG, 0x4, InitializeSuna_Str_MD_SND_ARG);
	RegisterTitle(0x10, NAKA_MAINFUNC_StylCnvWaitTtlFunc, 0x100000, 0x4, InitializeSuna_Str_TT_STYLCNVWAIT);
	RegisterTitle(0x11, NAKA_MAINFUNC_StylCnvModlTtlFunc, 0x110000, 0x4, InitializeSuna_Str_TT_STYLCNVMODL);
	RegisterTitle(0x12, NAKA_MAINFUNC_StylCnvCnvtTtlFunc, 0x120000, 0x4, InitializeSuna_Str_TT_STYLCNVCNVT);
	RegisterTitle(0x13, NAKA_MAINFUNC_StylCnvStorTtlFunc, 0x130000, 0x4, InitializeSuna_Str_TT_STYLCNVSTOR);
	RegisterTitle(0x14, NAKA_MAINFUNC_StylCnvTxtTtlFunc, 0x140000, 0x4, InitializeSuna_Str_TT_STYLCNVTXT);
	RegisterTitle(0x15, NAKA_MAINFUNC_StylCnvSelTtlFunc, 0x150000, 0x4, InitializeSuna_Str_TT_STYLCNVSEL);
	RegisterTitle(0x16, NAKA_MAINFUNC_StylCnvContTtlFunc, 0x160000, 0x4, InitializeSuna_Str_TT_STYLCNVCONT);
	RegisterTitle(0xb0, NAKA_MAINFUNC_CmpMenuTtlFunc, 0xb00000, 0x4, InitializeSuna_Str_TT_CMMENU);
	RegisterTitle(0xb1, NAKA_MAINFUNC_CmpBkslTtlFunc, 0xb10000, 0x4, InitializeSuna_Str_TT_CMBKSL);
	RegisterTitle(0xb2, NAKA_MAINFUNC_CmpBksl_STtlFunc, 0xb20000, 0x4, InitializeSuna_Str_TT_CMBKSL_S);
	RegisterTitle(0xb3, NAKA_APFUNC_DefaultFunction, 0xb30000, 0x4, InitializeSuna_Str_TT_CMNAME);
	RegisterTitle(0xb4, NAKA_MAINFUNC_CmpSetTtlFunc, 0xb40000, 0x4, InitializeSuna_Str_TT_CMSET);
	RegisterTitle(0xb5, NAKA_MAINFUNC_CmpRealTtlFunc, 0xb50000, 0x4, InitializeSuna_Str_TT_CMREAL);
	RegisterTitle(0xb6, NAKA_MAINFUNC_CmpStepTitleFunc, 0xb60000, 0x4, InitializeSuna_Str_TT_CMSTEP);
	RegisterTitle(0xb7, NAKA_APFUNC_DefaultFunction, 0xb70000, 0x4, InitializeSuna_Str_TT_CMBAL);
	RegisterTitle(0xb8, NAKA_MAINFUNC_CmpNcpTtlFunc, 0xb80000, 0x4, InitializeSuna_Str_TT_CMPNCP);
	RegisterTitle(0xb9, NAKA_MAINFUNC_S2cTtlFunc, 0xb90000, 0x4, InitializeSuna_Str_TT_CMSEQCP);
	RegisterTitle(0xba, NAKA_MAINFUNC_CmEsyTtlFunc, 0xba0000, 0x4, InitializeSuna_Str_TT_CMEASY);
	RegisterTitle(0xbb, NAKA_APFUNC_DefaultFunction, 0xbb0000, 0x4, InitializeSuna_Str_TT_CMBEND);
	RegisterTitle(0xbd, NAKA_APFUNC_DefaultFunction, 0xbd0000, 0x4, InitializeSuna_Str_TT_CMMODE);
	RegisterTitle(0xbe, NAKA_MAINFUNC_CstmCpTtlFunc, 0xbe0000, 0x4, InitializeSuna_Str_TT_CMCSTMCP);
	RegisterTitle(0xc8, NAKA_MAINFUNC_MspBkslTtlFunc, 0xc80000, 0x4, InitializeSuna_Str_TT_MSPBKSL);
	RegisterTitle(0xc9, NAKA_MAINFUNC_MspRecTtlFunc, 0xc90000, 0x4, InitializeSuna_Str_TT_MSPREC);
	RegisterTitle(0xca, NAKA_MAINFUNC_MspMenuTtlFunc, 0xca0000, 0x4, InitializeSuna_Str_TT_MSPMENU);
	RegisterTitle(0xcb, NAKA_MAINFUNC_MspNameTtlFunc, 0xcb0000, 0x4, InitializeSuna_Str_TT_MSPNAME);
	RegisterTitle(0xcc, NAKA_APFUNC_DefaultFunction, 0xcc0000, 0x4, InitializeSuna_Str_TT_MSPGROUP);
	RegisterTitle(0xdc, NAKA_MAINFUNC_SndArgTtlFunc, 0xdc0000, 0x4, InitializeSuna_Str_TT_SNDARG);
	RegisterTitle(0xed, NAKA_APFUNC_DefaultFunction, NAKA_VIEW_ApcSelScreen, 0x4, InitializeSuna_Str_TT_APCSEL);
}
