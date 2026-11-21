/* helper W, round 21r2, module 128 (display/scoop_display.s), form a: InitializeScoop, helper V's
   p6_V_21r1m128a.c with every identifier longer than 31 characters given a short alias (cc900-name lines below).
   Run r62 could not resolve it: V4.23 keeps 31 characters of a name, so the string names longer than that (the
   TT_SETONTON* titles) were cut to one symbol that has no address.  Rewritten by helper W's scratch script
   alias_long.py; otherwise V's C unchanged.
*/
/* cc900-name: IniScoop_Str_TT_SEAMPAMP1=InitializeScoop_Str_TT_SEAMPAMP1 */
/* cc900-name: IniScoop_Str_TT_SEAMPAMP2=InitializeScoop_Str_TT_SEAMPAMP2 */
/* cc900-name: IniScoop_Str_TT_SEAMPENV1=InitializeScoop_Str_TT_SEAMPENV1 */
/* cc900-name: IniScoop_Str_TT_SEAMPENV2=InitializeScoop_Str_TT_SEAMPENV2 */
/* cc900-name: IniScoop_Str_TT_SEAMPLFO1=InitializeScoop_Str_TT_SEAMPLFO1 */
/* cc900-name: IniScoop_Str_TT_SEFILBCF1=InitializeScoop_Str_TT_SEFILBCF1 */
/* cc900-name: IniScoop_Str_TT_SEFILBPF1=InitializeScoop_Str_TT_SEFILBPF1 */
/* cc900-name: IniScoop_Str_TT_SEFILENV1=InitializeScoop_Str_TT_SEFILENV1 */
/* cc900-name: IniScoop_Str_TT_SEFILENV2=InitializeScoop_Str_TT_SEFILENV2 */
/* cc900-name: IniScoop_Str_TT_SEFILFIL2=InitializeScoop_Str_TT_SEFILFIL2 */
/* cc900-name: IniScoop_Str_TT_SEFILH241=InitializeScoop_Str_TT_SEFILH241 */
/* cc900-name: IniScoop_Str_TT_SEFILHPQ1=InitializeScoop_Str_TT_SEFILHPQ1 */
/* cc900-name: IniScoop_Str_TT_SEFILL241=InitializeScoop_Str_TT_SEFILL241 */
/* cc900-name: IniScoop_Str_TT_SEFILLFO1=InitializeScoop_Str_TT_SEFILLFO1 */
/* cc900-name: IniScoop_Str_TT_SEFILLPQ1=InitializeScoop_Str_TT_SEFILLPQ1 */
/* cc900-name: IniScoop_Str_TT_SEPITENV1=InitializeScoop_Str_TT_SEPITENV1 */
/* cc900-name: IniScoop_Str_TT_SEPITENV2=InitializeScoop_Str_TT_SEPITENV2 */
/* cc900-name: IniScoop_Str_TT_SEPITLFO1=InitializeScoop_Str_TT_SEPITLFO1 */
/* cc900-name: IniScoop_Str_TT_SEPITPIT1=InitializeScoop_Str_TT_SEPITPIT1 */
/* cc900-name: IniScoop_Str_TT_SETONHYB1=InitializeScoop_Str_TT_SETONHYB1 */
/* cc900-name: IniScoop_Str_TT_SETONRAN1=InitializeScoop_Str_TT_SETONRAN1 */
/* cc900-name: IniScoop_Str_TT_SETONRAN2=InitializeScoop_Str_TT_SETONRAN2 */
/* cc900-name: IniScoop_Str_TT_SETONTON1=InitializeScoop_Str_TT_SETONTON1 */
/* cc900-name: IniScoop_Str_TT_SETONTON2=InitializeScoop_Str_TT_SETONTON2 */

#define NAKA_CLASS_ApFunction              0x1600002L
#define NAKA_CLASS_Class                   0x1600004L
#define NAKA_CLASS_Function                0x1600001L
#define NAKA_CLASS_MainFunction            0x1600003L
#define NAKA_CLASS_ResEvent                0x160000cL
#define NAKA_CLASS_ResMethod               0x160000dL
#define NAKA_CLASS_ResName                 0x160000fL
#define NAKA_CLASS_Viewable                0x1600010L
#define NMF_SeAmpAmp1TitleFunc   0x146000cL
#define NMF_SeAmpAmp2TitleFunc   0x146000dL
#define NMF_SeAmpEnv1TitleFunc   0x146000eL
#define NMF_SeAmpEnv2TitleFunc   0x146000fL
#define NMF_SeAmpLfo1TitleFunc   0x1460010L
#define NAKA_MAINFUNC_SeCopyTitleFunc      0x146001eL
#define NAKA_MAINFUNC_SeCtr2TitleFunc      0x146001cL
#define NAKA_MAINFUNC_SeCtr3TitleFunc      0x146001dL
#define NAKA_MAINFUNC_SeDigEffTitleFunc    0x146001bL
#define NAKA_MAINFUNC_SeEasyTitleFunc      0x1460002L
#define NMF_SeFilBcf1TitleFunc   0x1460016L
#define NMF_SeFilBpf1TitleFunc   0x1460015L
#define NMF_SeFilEnv1TitleFunc   0x1460018L
#define NMF_SeFilEnv2TitleFunc   0x1460019L
#define NMF_SeFilFil2TitleFunc   0x1460017L
#define NMF_SeFilH241TitleFunc   0x1460014L
#define NMF_SeFilHpq1TitleFunc   0x1460012L
#define NMF_SeFilL241TitleFunc   0x1460013L
#define NMF_SeFilLfo1TitleFunc   0x146001aL
#define NMF_SeFilLpq1TitleFunc   0x1460011L
#define NAKA_MAINFUNC_SeMenuModeFunc       0x1460000L
#define NAKA_MAINFUNC_SeMenuTitleFunc      0x1460001L
#define NMF_SePitEnv1TitleFunc   0x1460009L
#define NMF_SePitEnv2TitleFunc   0x146000aL
#define NMF_SePitLfo1TitleFunc   0x146000bL
#define NMF_SePitPit1TitleFunc   0x1460008L
#define NMF_SeTonHyb1TitleFunc   0x1460007L
#define NMF_SeTonRan1TitleFunc   0x1460005L
#define NMF_SeTonRan2TitleFunc   0x1460006L
#define NMF_SeTonTon1TitleFunc   0x1460003L
#define NMF_SeTonTon2TitleFunc   0x1460004L
#define NAKA_MAINFUNC_SeWrtMemTitleFunc    0x146001fL
#define NAKA_MAINFUNC_SeWrtSndTitleFunc    0x1460020L
#define TITLE_SEMENU                       0x1a00020L

struct objreg { long cls; void *proc; int count; void *base; };
extern void RegisterObjectTable(unsigned int, struct objreg *);
extern void RegisterMode(long id, long func, long a, int b, char *name);
extern void RegisterTitle(long id, long func, long view, int b, char *name);
extern long ApFunctionProc(long, long, long);
extern long ClassProc(long, long, long);
extern long FunctionProc(long, long, long);
extern long MainFunctionProc(long, long, long);
extern long ResEventProc(long, long, long);
extern long ResMethodProc(long, long, long);
extern long ResNameProc(long, long, long);
extern long ViewableProc(long, long, long);
extern int Scoop_ClassCount_166;
extern int Scoop_ResEventCount_1C6;
extern int Scoop_ResMethodCount_1E6;
extern char GUI_DisplayStructData_0x326[];
extern char GUI_DisplayStructData_0x59C[];
extern char GUI_DisplayStructData_0x750[];
extern char GUI_DisplayStructData_0x7D8[];
extern char IniScoop_Str_TT_SEAMPAMP1[];
extern char IniScoop_Str_TT_SEAMPAMP2[];
extern char IniScoop_Str_TT_SEAMPENV1[];
extern char IniScoop_Str_TT_SEAMPENV2[];
extern char IniScoop_Str_TT_SEAMPLFO1[];
extern char InitializeScoop_Str_TT_SECOPY[];
extern char InitializeScoop_Str_TT_SECTR2[];
extern char InitializeScoop_Str_TT_SECTR3[];
extern char InitializeScoop_Str_TT_SEDIGEFF[];
extern char InitializeScoop_Str_TT_SEEASY[];
extern char IniScoop_Str_TT_SEFILBCF1[];
extern char IniScoop_Str_TT_SEFILBPF1[];
extern char IniScoop_Str_TT_SEFILENV1[];
extern char IniScoop_Str_TT_SEFILENV2[];
extern char IniScoop_Str_TT_SEFILFIL2[];
extern char IniScoop_Str_TT_SEFILH241[];
extern char IniScoop_Str_TT_SEFILHPQ1[];
extern char IniScoop_Str_TT_SEFILL241[];
extern char IniScoop_Str_TT_SEFILLFO1[];
extern char IniScoop_Str_TT_SEFILLPQ1[];
extern char InitializeScoop_Str_TT_SEMENU[];
extern char IniScoop_Str_TT_SEPITENV1[];
extern char IniScoop_Str_TT_SEPITENV2[];
extern char IniScoop_Str_TT_SEPITLFO1[];
extern char IniScoop_Str_TT_SEPITPIT1[];
extern char IniScoop_Str_TT_SETONHYB1[];
extern char IniScoop_Str_TT_SETONRAN1[];
extern char IniScoop_Str_TT_SETONRAN2[];
extern char IniScoop_Str_TT_SETONTON1[];
extern char IniScoop_Str_TT_SETONTON2[];
extern char InitializeScoop_Str_TT_SEWRTMEM[];
extern char InitializeScoop_Str_TT_SEWRTSND[];
extern char Scoop_ApFunctionTable_126[];
extern char Scoop_ApFunctionTable_426[];
extern char Scoop_ClassTable_166[];
extern char Scoop_FunctionTable_106[];
extern char Scoop_FunctionTable_406[];
extern char Scoop_ResEventTable_1C6[];
extern char Scoop_ResMethodTable_1E6[];
extern char Scoop_ResNameTable_321[];
extern char Scoop_ResNameTable_322[];
extern char Scoop_ResNameTable_323[];
extern char Scoop_ResNameTable_324[];
extern char Scoop_ResNameTable_325[];
extern char Scoop_ResNameTable_326[];
extern char Scoop_ResNameTable_327[];
extern char Scoop_ResNameTable_328[];
extern char Scoop_ResNameTable_329[];
extern char Scoop_ResNameTable_32A[];
extern char Scoop_ResNameTable_32B[];
extern char Scoop_ResNameTable_32C[];
extern char Scoop_ResNameTable_32D[];
extern char Scoop_ResNameTable_32E[];
extern char Scoop_ResNameTable_32F[];
extern char Scoop_ResNameTable_330[];
extern char Scoop_ResNameTable_331[];
extern char Scoop_ResNameTable_332[];
extern char Scoop_ResNameTable_333[];
extern char Scoop_ResNameTable_334[];
extern char Scoop_ResNameTable_335[];
extern char Scoop_ResNameTable_336[];
extern char Scoop_ResNameTable_337[];
extern char Scoop_ResNameTable_338[];
extern char Scoop_ResNameTable_339[];
extern char Scoop_ResNameTable_33A[];
extern char Scoop_ResNameTable_33B[];
extern char Scoop_ResNameTable_33C[];
extern char Scoop_ResNameTable_33D[];
extern char Scoop_ResNameTable_33E[];
extern char Scoop_ResNameTable_33F[];
extern char Scoop_ViewableTable_020[];
extern char Scoop_ViewableTable_021[];
extern char Scoop_ViewableTable_022[];
extern char Scoop_ViewableTable_023[];
extern char Scoop_ViewableTable_024[];
extern char Scoop_ViewableTable_025[];
extern char Scoop_ViewableTable_026[];
extern char Scoop_ViewableTable_027[];
extern char Scoop_ViewableTable_028[];
extern char Scoop_ViewableTable_029[];
extern char Scoop_ViewableTable_02A[];
extern char Scoop_ViewableTable_02B[];
extern char Scoop_ViewableTable_02C[];
extern char Scoop_ViewableTable_02D[];
extern char Scoop_ViewableTable_02E[];
extern char Scoop_ViewableTable_02F[];
extern char Scoop_ViewableTable_030[];
extern char Scoop_ViewableTable_031[];
extern char Scoop_ViewableTable_032[];
extern char Scoop_ViewableTable_033[];
extern char Scoop_ViewableTable_034[];
extern char Scoop_ViewableTable_035[];
extern char Scoop_ViewableTable_036[];
extern char Scoop_ViewableTable_037[];
extern char Scoop_ViewableTable_038[];
extern char Scoop_ViewableTable_039[];
extern char Scoop_ViewableTable_03A[];
extern char Scoop_ViewableTable_03B[];
extern char Scoop_ViewableTable_03C[];
extern char Scoop_ViewableTable_03D[];
extern char Scoop_ViewableTable_03E[];
extern char Scoop_ViewableTable_03F[];

void InitializeScoop(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = Scoop_ClassCount_166;
	reg.base = Scoop_ClassTable_166;
	RegisterObjectTable(0x166, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = Scoop_ResEventCount_1C6;
	reg.base = Scoop_ResEventTable_1C6;
	RegisterObjectTable(0x1c6, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = Scoop_ResMethodCount_1E6;
	reg.base = Scoop_ResMethodTable_1E6;
	RegisterObjectTable(0x1e6, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x0;
	reg.base = Scoop_ApFunctionTable_126;
	RegisterObjectTable(0x126, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x0;
	reg.base = Scoop_ApFunctionTable_426;
	RegisterObjectTable(0x426, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x0;
	reg.base = Scoop_FunctionTable_106;
	RegisterObjectTable(0x106, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x0;
	reg.base = Scoop_FunctionTable_406;
	RegisterObjectTable(0x406, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x21;
	reg.base = GUI_DisplayStructData_0x750;
	RegisterObjectTable(0x146, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x21;
	reg.base = GUI_DisplayStructData_0x7D8;
	RegisterObjectTable(0x446, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_020;
	RegisterObjectTable(0x20, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = GUI_DisplayStructData_0x326;
	RegisterObjectTable(0x320, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_021;
	RegisterObjectTable(0x21, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_321;
	RegisterObjectTable(0x321, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_022;
	RegisterObjectTable(0x22, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_322;
	RegisterObjectTable(0x322, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_023;
	RegisterObjectTable(0x23, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_323;
	RegisterObjectTable(0x323, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_024;
	RegisterObjectTable(0x24, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_324;
	RegisterObjectTable(0x324, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_025;
	RegisterObjectTable(0x25, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_325;
	RegisterObjectTable(0x325, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_026;
	RegisterObjectTable(0x26, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_326;
	RegisterObjectTable(0x326, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_027;
	RegisterObjectTable(0x27, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_327;
	RegisterObjectTable(0x327, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_028;
	RegisterObjectTable(0x28, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_328;
	RegisterObjectTable(0x328, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_029;
	RegisterObjectTable(0x29, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_329;
	RegisterObjectTable(0x329, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_02A;
	RegisterObjectTable(0x2a, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_32A;
	RegisterObjectTable(0x32a, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_02B;
	RegisterObjectTable(0x2b, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_32B;
	RegisterObjectTable(0x32b, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_02C;
	RegisterObjectTable(0x2c, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_32C;
	RegisterObjectTable(0x32c, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_02D;
	RegisterObjectTable(0x2d, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_32D;
	RegisterObjectTable(0x32d, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_02E;
	RegisterObjectTable(0x2e, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_32E;
	RegisterObjectTable(0x32e, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_02F;
	RegisterObjectTable(0x2f, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_32F;
	RegisterObjectTable(0x32f, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_030;
	RegisterObjectTable(0x30, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_330;
	RegisterObjectTable(0x330, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_031;
	RegisterObjectTable(0x31, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_331;
	RegisterObjectTable(0x331, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_032;
	RegisterObjectTable(0x32, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_332;
	RegisterObjectTable(0x332, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_033;
	RegisterObjectTable(0x33, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_333;
	RegisterObjectTable(0x333, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_034;
	RegisterObjectTable(0x34, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_334;
	RegisterObjectTable(0x334, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_035;
	RegisterObjectTable(0x35, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_335;
	RegisterObjectTable(0x335, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_036;
	RegisterObjectTable(0x36, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_336;
	RegisterObjectTable(0x336, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_037;
	RegisterObjectTable(0x37, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_337;
	RegisterObjectTable(0x337, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_038;
	RegisterObjectTable(0x38, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_338;
	RegisterObjectTable(0x338, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_039;
	RegisterObjectTable(0x39, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_339;
	RegisterObjectTable(0x339, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_03A;
	RegisterObjectTable(0x3a, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_33A;
	RegisterObjectTable(0x33a, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_03B;
	RegisterObjectTable(0x3b, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_33B;
	RegisterObjectTable(0x33b, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_03C;
	RegisterObjectTable(0x3c, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_33C;
	RegisterObjectTable(0x33c, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_03D;
	RegisterObjectTable(0x3d, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_33D;
	RegisterObjectTable(0x33d, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_03E;
	RegisterObjectTable(0x3e, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_33E;
	RegisterObjectTable(0x33e, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Scoop_ViewableTable_03F;
	RegisterObjectTable(0x3f, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Scoop_ResNameTable_33F;
	RegisterObjectTable(0x33f, &reg);
	RegisterMode(0x3, NAKA_MAINFUNC_SeMenuModeFunc, TITLE_SEMENU, 0x6, GUI_DisplayStructData_0x59C);
	RegisterTitle(0x20, NAKA_MAINFUNC_SeMenuTitleFunc, 0x200000, 0x6, InitializeScoop_Str_TT_SEMENU);
	RegisterTitle(0x21, NAKA_MAINFUNC_SeEasyTitleFunc, 0x210000, 0x6, InitializeScoop_Str_TT_SEEASY);
	RegisterTitle(0x22, NMF_SeTonTon1TitleFunc, 0x220000, 0x6, IniScoop_Str_TT_SETONTON1);
	RegisterTitle(0x23, NMF_SeTonTon2TitleFunc, 0x230000, 0x6, IniScoop_Str_TT_SETONTON2);
	RegisterTitle(0x24, NMF_SeTonRan1TitleFunc, 0x240000, 0x6, IniScoop_Str_TT_SETONRAN1);
	RegisterTitle(0x25, NMF_SeTonRan2TitleFunc, 0x250000, 0x6, IniScoop_Str_TT_SETONRAN2);
	RegisterTitle(0x26, NMF_SeTonHyb1TitleFunc, 0x260000, 0x6, IniScoop_Str_TT_SETONHYB1);
	RegisterTitle(0x27, NMF_SePitPit1TitleFunc, 0x270000, 0x6, IniScoop_Str_TT_SEPITPIT1);
	RegisterTitle(0x28, NMF_SePitEnv1TitleFunc, 0x280000, 0x6, IniScoop_Str_TT_SEPITENV1);
	RegisterTitle(0x29, NMF_SePitEnv2TitleFunc, 0x290000, 0x6, IniScoop_Str_TT_SEPITENV2);
	RegisterTitle(0x2a, NMF_SePitLfo1TitleFunc, 0x2a0000, 0x6, IniScoop_Str_TT_SEPITLFO1);
	RegisterTitle(0x2b, NMF_SeAmpAmp1TitleFunc, 0x2b0000, 0x6, IniScoop_Str_TT_SEAMPAMP1);
	RegisterTitle(0x2c, NMF_SeAmpAmp2TitleFunc, 0x2c0000, 0x6, IniScoop_Str_TT_SEAMPAMP2);
	RegisterTitle(0x2d, NMF_SeAmpEnv1TitleFunc, 0x2d0000, 0x6, IniScoop_Str_TT_SEAMPENV1);
	RegisterTitle(0x2e, NMF_SeAmpEnv2TitleFunc, 0x2e0000, 0x6, IniScoop_Str_TT_SEAMPENV2);
	RegisterTitle(0x2f, NMF_SeAmpLfo1TitleFunc, 0x2f0000, 0x6, IniScoop_Str_TT_SEAMPLFO1);
	RegisterTitle(0x30, NMF_SeFilLpq1TitleFunc, 0x300000, 0x6, IniScoop_Str_TT_SEFILLPQ1);
	RegisterTitle(0x31, NMF_SeFilHpq1TitleFunc, 0x310000, 0x6, IniScoop_Str_TT_SEFILHPQ1);
	RegisterTitle(0x32, NMF_SeFilL241TitleFunc, 0x320000, 0x6, IniScoop_Str_TT_SEFILL241);
	RegisterTitle(0x33, NMF_SeFilH241TitleFunc, 0x330000, 0x6, IniScoop_Str_TT_SEFILH241);
	RegisterTitle(0x34, NMF_SeFilBpf1TitleFunc, 0x340000, 0x6, IniScoop_Str_TT_SEFILBPF1);
	RegisterTitle(0x35, NMF_SeFilBcf1TitleFunc, 0x350000, 0x6, IniScoop_Str_TT_SEFILBCF1);
	RegisterTitle(0x36, NMF_SeFilFil2TitleFunc, 0x360000, 0x6, IniScoop_Str_TT_SEFILFIL2);
	RegisterTitle(0x37, NMF_SeFilEnv1TitleFunc, 0x370000, 0x6, IniScoop_Str_TT_SEFILENV1);
	RegisterTitle(0x38, NMF_SeFilEnv2TitleFunc, 0x380000, 0x6, IniScoop_Str_TT_SEFILENV2);
	RegisterTitle(0x39, NMF_SeFilLfo1TitleFunc, 0x390000, 0x6, IniScoop_Str_TT_SEFILLFO1);
	RegisterTitle(0x3a, NAKA_MAINFUNC_SeDigEffTitleFunc, 0x3a0000, 0x6, InitializeScoop_Str_TT_SEDIGEFF);
	RegisterTitle(0x3b, NAKA_MAINFUNC_SeCtr2TitleFunc, 0x3b0000, 0x6, InitializeScoop_Str_TT_SECTR2);
	RegisterTitle(0x3c, NAKA_MAINFUNC_SeCtr3TitleFunc, 0x3c0000, 0x6, InitializeScoop_Str_TT_SECTR3);
	RegisterTitle(0x3d, NAKA_MAINFUNC_SeCopyTitleFunc, 0x3d0000, 0x6, InitializeScoop_Str_TT_SECOPY);
	RegisterTitle(0x3e, NAKA_MAINFUNC_SeWrtMemTitleFunc, 0x3e0000, 0x6, InitializeScoop_Str_TT_SEWRTMEM);
	RegisterTitle(0x3f, NAKA_MAINFUNC_SeWrtSndTitleFunc, 0x3f0000, 0x6, InitializeScoop_Str_TT_SEWRTSND);
}
