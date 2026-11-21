/* helper V, round 21r1, module 274 (display/graphics_text_vga.s): InitializeRoot, the NAKA root module's
   registration: thirteen object tables through RegisterObjectTable (a 14-byte record in the frame, at (xsp)),
   mode 0 and titles 0 / 0xff.  The scoop_display.s macros RegObjTable / RegObjTabl / RegMode / RegTitle are this
   C's calls: RegObjTable reads the count from a ROM word, RegObjTabl stores it as a constant.  RegisterMode /
   RegisterTitle take their 4th (int) and 5th (pointer) arguments on the stack (RegisterMode's C in
   ui_widget_defs_o3xr.c; RegisterTitle's frame reads the same slots). */

#define NAKA_CLASS_Function          0x1600001L
#define NAKA_CLASS_ApFunction        0x1600002L
#define NAKA_CLASS_MainFunction      0x1600003L
#define NAKA_CLASS_Class             0x1600004L
#define NAKA_CLASS_ResEvent          0x160000cL
#define NAKA_CLASS_ResMethod         0x160000dL
#define NAKA_CLASS_ResName           0x160000fL
#define NAKA_CLASS_Viewable          0x1600010L
#define NAKA_APFUNC_DefaultFunction  0x1200000L
#define NAKA_MAINFUNC_CheckTitleFunc 0x1400009L
#define NAKA_VIEW_CheckTitle         0xff0000L
#define TITLE_PS                     0x1a00000L

struct objreg { long cls; void *proc; int count; void *base; };
extern void RegisterObjectTable(unsigned int, struct objreg *);
extern void RegisterMode(long id, long func, long a, int b, char *name);
extern void RegisterTitle(long id, long func, long view, int b, char *name);
extern long ClassProc(long, long, long);
extern long ResEventProc(long, long, long);
extern long ResMethodProc(long, long, long);
extern long ApFunctionProc(long, long, long);
extern long FunctionProc(long, long, long);
extern long MainFunctionProc(long, long, long);
extern long ViewableProc(long, long, long);
extern long ResNameProc(long, long, long);
extern int Root_ClassCount_160;
extern int Root_ResEventCount_1C0;
extern int Root_ResMethodCount_1E0;
extern char Root_ClassTable_160[];
extern char Root_ResEventTable_1C0[];
extern char Root_ResMethodTable_1E0[];
extern char Root_ApFunctionTable_120[];
extern char Root_ApFunctionTable_420[];
extern char Root_FunctionTable_100[];
extern char WidgetName_InitPtrTable[];
extern char Root_MainFunctionTable_140[];
extern char Root_MainFunctionTable_440[];
extern char Root_ViewableTable_000[];
extern char Root_ResNameTable_300[];
extern char Root_ViewableTable_0FF[];
extern char Root_ResNameTable_3FF[];
extern char InitializeRoot_Str_MD_PS[];
extern char InitializeRoot_Str_TT_PS[];
extern char InitializeRoot_Str_TT_CHECK[];

void InitializeRoot(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = Root_ClassCount_160;
	reg.base = Root_ClassTable_160;
	RegisterObjectTable(0x160, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = Root_ResEventCount_1C0;
	reg.base = Root_ResEventTable_1C0;
	RegisterObjectTable(0x1c0, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = Root_ResMethodCount_1E0;
	reg.base = Root_ResMethodTable_1E0;
	RegisterObjectTable(0x1e0, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0xc;
	reg.base = Root_ApFunctionTable_120;
	RegisterObjectTable(0x120, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0xc;
	reg.base = Root_ApFunctionTable_420;
	RegisterObjectTable(0x420, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x160;
	reg.base = Root_FunctionTable_100;
	RegisterObjectTable(0x100, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x160;
	reg.base = WidgetName_InitPtrTable;
	RegisterObjectTable(0x400, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0xd;
	reg.base = Root_MainFunctionTable_140;
	RegisterObjectTable(0x140, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0xd;
	reg.base = Root_MainFunctionTable_440;
	RegisterObjectTable(0x440, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x33;
	reg.base = Root_ViewableTable_000;
	RegisterObjectTable(0, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x33;
	reg.base = Root_ResNameTable_300;
	RegisterObjectTable(0x300, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 9;
	reg.base = Root_ViewableTable_0FF;
	RegisterObjectTable(0xff, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 9;
	reg.base = Root_ResNameTable_3FF;
	RegisterObjectTable(0x3ff, &reg);
	RegisterMode(0, NAKA_APFUNC_DefaultFunction, TITLE_PS, 0, InitializeRoot_Str_MD_PS);
	RegisterTitle(0, NAKA_APFUNC_DefaultFunction, 0, 0, InitializeRoot_Str_TT_PS);
	RegisterTitle(0xff, NAKA_MAINFUNC_CheckTitleFunc, NAKA_VIEW_CheckTitle, 0, InitializeRoot_Str_TT_CHECK);
}
