/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_V_21r1m159a.c (2026-11-21-7-p6-r62)
   sha256 3b854839463474206bba48bec49442612790a8149b2b7a15446ca0a38aacc56b (tar-sha256); compiled at -O3 -XS -Xr */
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
