/* Functions of factory_test/test_init.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
extern void InitializeHama(void);

void InitializeHama(void)
{
	struct objreg reg;
	struct objreg *p;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = *(int *)(HamaStr_HamaList + 0xa);
	reg.base = Hama_ClassTable_169;
	p = &reg;
	RegisterObjectTable(0x169, p);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = *(int *)(HamaStr_EV_INDEX_PUTS + 0xe);
	reg.base = Hama_ResEventTable_1C9;
	p = &reg;
	RegisterObjectTable(0x1c9, p);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = *(int *)(HamaStr_MT_CONTINUE + 0xc);
	reg.base = Hama_ResMethodTable_1E9;
	p = &reg;
	RegisterObjectTable(0x1e9, p);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x2;
	reg.base = Hama_ApFuncTable_129;
	p = &reg;
	RegisterObjectTable(0x129, p);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x2;
	reg.base = Hama_ApFuncTable_429;
	p = &reg;
	RegisterObjectTable(0x429, p);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x4b;
	reg.base = Hama_FunctionTable_109;
	p = &reg;
	RegisterObjectTable(0x109, p);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x4b;
	reg.base = Hama_ModeParam_Table;
	p = &reg;
	RegisterObjectTable(0x409, p);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x1;
	reg.base = FDTest_CfgName_FDDTest + 0x1e;
	p = &reg;
	RegisterObjectTable(0x149, p);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x1;
	reg.base = FDTest_CfgName_FDDTest + 0x26;
	p = &reg;
	RegisterObjectTable(0x449, p);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x0;
	reg.base = String_CONSOLE + 0x8;
	p = &reg;
	RegisterObjectTable(0x7f, p);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x0;
	reg.base = FDTest_DataBlock_Table + 0x68;
	p = &reg;
	RegisterObjectTable(0x37f, p);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1a;
	reg.base = String_CONSOLE + 0xc;
	p = &reg;
	RegisterObjectTable(0xfc, p);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1a;
	reg.base = FDTest_Config_Table;
	p = &reg;
	RegisterObjectTable(0x3fc, p);
	RegisterTitle(0x7f, NAKA_MAINFUNC_TestTitleFunc, NAKA_VIEW_FDD_TEST, 0x9, FDTest_CfgName_FDDTest + 0xa);
	RegisterTitle(0xfc, NAKA_MAINFUNC_TestTitleFunc, NAKA_VIEW_FDD_TEST, 0x9, FDTest_CfgName_FDDTest + 0x14);
}
