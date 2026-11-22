/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_21r1m159ta.c (2026-11-21-7-p6-r62)
   sha256 b432b8323e2a5eb7674a251cb7e8ae5a025483e6e8b69df5cd5c0860baf3d736 (tar-sha256); compiled at -Xr */
#define NAKA_CLASS_ApFunction              0x1600002L
#define NAKA_CLASS_Class                   0x1600004L
#define NAKA_CLASS_Function                0x1600001L
#define NAKA_CLASS_MainFunction            0x1600003L
#define NAKA_CLASS_ResEvent                0x160000cL
#define NAKA_CLASS_ResMethod               0x160000dL
#define NAKA_CLASS_ResName                 0x160000fL
#define NAKA_CLASS_Viewable                0x1600010L
#define NAKA_MAINFUNC_TestTitleFunc        0x1490000L
#define NAKA_VIEW_FDD_TEST                 0xfc0000L
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
extern char FDTest_CfgName_FDDTest[];
extern char FDTest_Config_Table[];
extern char FDTest_DataBlock_Table[];
extern char HamaStr_EV_INDEX_PUTS[];
extern char HamaStr_HamaList[];
extern char HamaStr_MT_CONTINUE[];
extern char Hama_ApFuncTable_129[];
extern char Hama_ApFuncTable_429[];
extern char Hama_ClassTable_169[];
extern char Hama_FunctionTable_109[];
extern char Hama_ModeParam_Table[];
extern char Hama_ResEventTable_1C9[];
extern char Hama_ResMethodTable_1E9[];
extern char String_CONSOLE[];
void InitializeHama(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = *(int *)(HamaStr_HamaList + 0xa);
	reg.base = Hama_ClassTable_169;
	RegisterObjectTable(0x169, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = *(int *)(HamaStr_EV_INDEX_PUTS + 0xe);
	reg.base = Hama_ResEventTable_1C9;
	RegisterObjectTable(0x1c9, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = *(int *)(HamaStr_MT_CONTINUE + 0xc);
	reg.base = Hama_ResMethodTable_1E9;
	RegisterObjectTable(0x1e9, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x2;
	reg.base = Hama_ApFuncTable_129;
	RegisterObjectTable(0x129, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x2;
	reg.base = Hama_ApFuncTable_429;
	RegisterObjectTable(0x429, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x4b;
	reg.base = Hama_FunctionTable_109;
	RegisterObjectTable(0x109, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x4b;
	reg.base = Hama_ModeParam_Table;
	RegisterObjectTable(0x409, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x1;
	reg.base = FDTest_CfgName_FDDTest + 0x1e;
	RegisterObjectTable(0x149, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x1;
	reg.base = FDTest_CfgName_FDDTest + 0x26;
	RegisterObjectTable(0x449, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x0;
	reg.base = String_CONSOLE + 0x8;
	RegisterObjectTable(0x7f, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x0;
	reg.base = FDTest_DataBlock_Table + 0x68;
	RegisterObjectTable(0x37f, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1a;
	reg.base = String_CONSOLE + 0xc;
	RegisterObjectTable(0xfc, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1a;
	reg.base = FDTest_Config_Table;
	RegisterObjectTable(0x3fc, &reg);
	RegisterTitle(0x7f, NAKA_MAINFUNC_TestTitleFunc, NAKA_VIEW_FDD_TEST, 0x9, FDTest_CfgName_FDDTest + 0xa);
	RegisterTitle(0xfc, NAKA_MAINFUNC_TestTitleFunc, NAKA_VIEW_FDD_TEST, 0x9, FDTest_CfgName_FDDTest + 0x14);
}
