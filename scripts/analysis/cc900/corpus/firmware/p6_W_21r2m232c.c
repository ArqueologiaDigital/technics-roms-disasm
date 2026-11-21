/* helper W, round 21r2, module 232 (sequencer/sequencer_ui.s), form c: InitializeYoko, helper V's
   p6_V_21r1m232a.c with every identifier longer than 31 characters given a short alias (cc900-name lines below).
   Run r62 differed in one instruction only (+2305, the string pushed for title 0x76): V4.23 keeps 31 characters of a
   name, so InitializeYoko_Str_TT_DPMDLYSMFLYR was linked as InitializeYoko_Str_TT_DPMDLYSMF.  Rewritten by helper
   W's scratch script alias_long.py; otherwise V's C unchanged.
   cc900-options: -O3 -Xr
*/
/* cc900-name: IniKubo_Str_MD_ENTERTAINER=InitializeKubo_Str_MD_ENTERTAINER */
/* cc900-name: IniKubo_Str_TT_SDEQUALIZER=InitializeKubo_Str_TT_SDEQUALIZER */
/* cc900-name: IniKubo_Str_TT_SQNOTECYCP=InitializeKubo_Str_TT_SQNOTECYCP */
/* cc900-name: IniYoko_Str_TT_DPMDLYSMFLYR=InitializeYoko_Str_TT_DPMDLYSMFLYR */
/* cc900-name: IniYoko_Str_TT_SQEASYNAME=InitializeYoko_Str_TT_SQEASYNAME */

#define NAKA_APFUNC_DefaultFunction        0x1200000L
#define NAKA_CLASS_ApFunction              0x1600002L
#define NAKA_CLASS_Class                   0x1600004L
#define NAKA_CLASS_Function                0x1600001L
#define NAKA_CLASS_MainFunction            0x1600003L
#define NAKA_CLASS_ResEvent                0x160000cL
#define NAKA_CLASS_ResMethod               0x160000dL
#define NAKA_CLASS_ResName                 0x160000fL
#define NAKA_CLASS_Viewable                0x1600010L
#define NAKA_MAINFUNC_DemoMenuTtlFunc      0x1470018L
#define NAKA_MAINFUNC_DemoModeFunc         0x1470017L
#define NAKA_MAINFUNC_DemoRhyTtlFunc       0x147001bL
#define NAKA_MAINFUNC_DemoSoundTtlFunc     0x147001aL
#define NAKA_MAINFUNC_DemoStyleTtlFunc     0x1470019L
#define NAKA_MAINFUNC_DkMdlyPlyTtlFunc     0x147000bL
#define NAKA_MAINFUNC_DpDocTtlFunc         0x1470010L
#define NAKA_MAINFUNC_DpMdlyDocTtlFunc     0x147000cL
#define NAKA_MAINFUNC_DpMdlyPdTtlFunc      0x147000dL
#define NMF_DpMdlySmfLyrTtlFunc  0x147000fL
#define NAKA_MAINFUNC_DpMdlySmfTtlFunc     0x147000eL
#define NAKA_MAINFUNC_DpPdTtlFunc          0x1470011L
#define NAKA_MAINFUNC_DpSmfLyrTtlFunc      0x1470013L
#define NAKA_MAINFUNC_DpSmfTtlFunc         0x1470012L
#define NAKA_MAINFUNC_EtmenuTitleFunc      0x148002aL
#define NAKA_MAINFUNC_HelpModeFunc         0x1480026L
#define NAKA_MAINFUNC_HelpTitleFunc        0x1480027L
#define NAKA_MAINFUNC_SdAccillTitleFunc    0x1480022L
#define NAKA_MAINFUNC_SdDspeffTitleFunc    0x1480021L
#define NAKA_MAINFUNC_SdRevsetTitleFunc    0x1480020L
#define NAKA_MAINFUNC_SeqEditModeFunc      0x1480008L
#define NAKA_MAINFUNC_SeqErecModeFunc      0x1480007L
#define NAKA_MAINFUNC_SeqModeFunc          0x1480004L
#define NAKA_MAINFUNC_SeqPlayModeFunc      0x1480006L
#define NAKA_MAINFUNC_SeqRealModeFunc      0x1480005L
#define NAKA_MAINFUNC_SeqStepModeFunc      0x1470014L
#define NAKA_MAINFUNC_SqAdlyTitleFunc      0x1480019L
#define NAKA_MAINFUNC_SqAftSetTtlFunc      0x1470003L
#define NMF_SqDrmCycpTitleFunc   0x1480025L
#define NAKA_MAINFUNC_SqDrmEdtTitleFunc    0x148001aL
#define NAKA_MAINFUNC_SqDrmSelTitleFunc    0x148001bL
#define NAKA_MAINFUNC_SqMcpyTitleFunc      0x1480014L
#define NAKA_MAINFUNC_SqMdelTitleFunc      0x148000eL
#define NAKA_MAINFUNC_SqMdlyPlyTtlFunc     0x147000aL
#define NAKA_MAINFUNC_SqMersTitleFunc      0x148000fL
#define NAKA_MAINFUNC_SqMinsTitleFunc      0x1480015L
#define NAKA_MAINFUNC_SqNcngTitleFunc      0x1480012L
#define NMF_SqNoteCycpTitleFunc  0x1480024L
#define NMF_SqNoteEdtTitleFunc   0x148001cL
#define NMF_SqNoteSelTitleFunc   0x148001dL
#define NAKA_MAINFUNC_SqPlayTitleFunc      0x148000aL
#define NAKA_MAINFUNC_SqPunchTitleFunc     0x148000bL
#define NAKA_MAINFUNC_SqPunchmTitleFunc    0x148000cL
#define NAKA_MAINFUNC_SqQtzTitleFunc       0x148000dL
#define NMF_SqRealRecTitleFunc   0x1480009L
#define NAKA_MAINFUNC_SqSngNameTtlFunc     0x1470005L
#define NAKA_MAINFUNC_SqSngSelTtlFunc      0x1470004L
#define NAKA_MAINFUNC_SqSngcpTitleFunc     0x1480017L
#define NAKA_MAINFUNC_SqSoclTitleFunc      0x1480013L
#define NAKA_MAINFUNC_SqStepTtlFunc        0x1470016L
#define NAKA_MAINFUNC_SqTrAsPsTtlFunc      0x1470008L
#define NAKA_MAINFUNC_SqTrAsTtlFunc        0x1470006L
#define NAKA_MAINFUNC_SqTrSelTtlFunc       0x1470015L
#define NAKA_MAINFUNC_SqTrclTitleFunc      0x1480016L
#define NAKA_MAINFUNC_SqTrmgTitleFunc      0x1480018L
#define NAKA_MAINFUNC_SqTrnsTitleFunc      0x1480011L
#define NAKA_MAINFUNC_SqVcngTitleFunc      0x1480010L
#define NAKA_VIEW_DemoMenu                 0xe00000L
#define NAKA_VIEW_DemoRhy                  0xe30000L
#define NAKA_VIEW_DemoSound                0xe20000L
#define NAKA_VIEW_DemoStyle                0xe10000L
#define TITLE_DEMOMENU                     0x1a000e0L
#define TITLE_ETMENU                       0x1a000d6L
#define TITLE_SQEASYREC                    0x1a00083L
#define TITLE_SQEMENU                      0x1a00093L
#define TITLE_SQMENU                       0x1a00080L
#define TITLE_SQPLAY                       0x1a00081L
#define TITLE_SQREALREC                    0x1a00085L
#define TITLE_SQTRSEL                      0x1a00089L
#define TITLE_SWHELP                       0x1a000e7L

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
extern int EffectsEditor_GapByte;
extern int Kubo_ClassCount_168;
extern int Kubo_ResEventCount_1C8;
extern int Yoko_ClassCount_167;
extern int Yoko_ResEventCount_1C7;
extern int Yoko_ResMethodCount_1E7;
extern char EvtEffDraw_PtrTable[];
extern char EvtName_PtrTable[];
extern char IniKubo_Str_MD_ENTERTAINER[];
extern char InitializeKubo_Str_MD_HELP[];
extern char InitializeKubo_Str_MD_SEQ[];
extern char InitializeKubo_Str_MD_SEQ_EDIT[];
extern char InitializeKubo_Str_MD_SEQ_EREC[];
extern char InitializeKubo_Str_MD_SEQ_PLAY[];
extern char InitializeKubo_Str_MD_SEQ_REAL[];
extern char InitializeKubo_Str_TT_ETMENU[];
extern char InitializeKubo_Str_TT_SDACCILL[];
extern char InitializeKubo_Str_TT_SDDSPEFF[];
extern char IniKubo_Str_TT_SDEQUALIZER[];
extern char InitializeKubo_Str_TT_SDREVSET[];
extern char InitializeKubo_Str_TT_SQADVDLY[];
extern char InitializeKubo_Str_TT_SQCMENU[];
extern char InitializeKubo_Str_TT_SQCYCPLY[];
extern char InitializeKubo_Str_TT_SQCYCREC[];
extern char InitializeKubo_Str_TT_SQDRMCYCP[];
extern char InitializeKubo_Str_TT_SQDRMEDT[];
extern char InitializeKubo_Str_TT_SQDRMSEL[];
extern char InitializeKubo_Str_TT_SQEASYREC[];
extern char InitializeKubo_Str_TT_SQEMENU[];
extern char InitializeKubo_Str_TT_SQMCP[];
extern char InitializeKubo_Str_TT_SQMDEL[];
extern char InitializeKubo_Str_TT_SQMENU[];
extern char InitializeKubo_Str_TT_SQMERS[];
extern char InitializeKubo_Str_TT_SQMETBAL[];
extern char InitializeKubo_Str_TT_SQMINS[];
extern char InitializeKubo_Str_TT_SQNOTECNG[];
extern char IniKubo_Str_TT_SQNOTECYCP[];
extern char InitializeKubo_Str_TT_SQNOTEEDT[];
extern char InitializeKubo_Str_TT_SQNOTESEL[];
extern char InitializeKubo_Str_TT_SQPLAY[];
extern char InitializeKubo_Str_TT_SQPNLWR[];
extern char InitializeKubo_Str_TT_SQPNLWRM[];
extern char InitializeKubo_Str_TT_SQPUNCH[];
extern char InitializeKubo_Str_TT_SQPUNCHM[];
extern char InitializeKubo_Str_TT_SQQTZ[];
extern char InitializeKubo_Str_TT_SQREALREC[];
extern char InitializeKubo_Str_TT_SQSNGCLR[];
extern char InitializeKubo_Str_TT_SQSNGCP[];
extern char InitializeKubo_Str_TT_SQSNGCPC[];
extern char InitializeKubo_Str_TT_SQTRKCLR[];
extern char InitializeKubo_Str_TT_SQTRKMRG[];
extern char InitializeKubo_Str_TT_SQTRNS[];
extern char InitializeKubo_Str_TT_SQVELOCNG[];
extern char InitializeKubo_Str_TT_SWHELP[];
extern char InitializeYoko_Str_MD_DEMO[];
extern char InitializeYoko_Str_TT_DEMOMENU[];
extern char InitializeYoko_Str_TT_DEMORHY[];
extern char InitializeYoko_Str_TT_DEMOSOUND[];
extern char InitializeYoko_Str_TT_DEMOSTYLE[];
extern char InitializeYoko_Str_TT_DKMDLYPLY[];
extern char InitializeYoko_Str_TT_DPDOC[];
extern char InitializeYoko_Str_TT_DPMDLYDOC[];
extern char InitializeYoko_Str_TT_DPMDLYPD[];
extern char InitializeYoko_Str_TT_DPMDLYSMF[];
extern char IniYoko_Str_TT_DPMDLYSMFLYR[];
extern char InitializeYoko_Str_TT_DPPD[];
extern char InitializeYoko_Str_TT_DPSMF[];
extern char InitializeYoko_Str_TT_DPSMFLYR[];
extern char InitializeYoko_Str_TT_SQAFTSET[];
extern char IniYoko_Str_TT_SQEASYNAME[];
extern char InitializeYoko_Str_TT_SQMDLYPLY[];
extern char InitializeYoko_Str_TT_SQSNGNAME[];
extern char InitializeYoko_Str_TT_SQSNGSEL[];
extern char InitializeYoko_Str_TT_SQSTEP[];
extern char InitializeYoko_Str_TT_SQSTEPBAL[];
extern char InitializeYoko_Str_TT_SQTRAS[];
extern char InitializeYoko_Str_TT_SQTRASPS[];
extern char InitializeYoko_Str_TT_SQTRSEL[];
extern char Kubo_ApFuncNameTable_428[];
extern char Kubo_ApFuncTable_128[];
extern char Kubo_ClassTable_168[];
extern char Kubo_MainFunctionTable_148[];
extern char Kubo_MainFunctionTable_448[];
extern char Kubo_ResNameTable_30A[];
extern char Kubo_ResNameTable_30B[];
extern char Kubo_ResNameTable_30C[];
extern char Kubo_ResNameTable_30E[];
extern char Kubo_ResNameTable_380[];
extern char Kubo_ResNameTable_381[];
extern char Kubo_ResNameTable_382[];
extern char Kubo_ResNameTable_383[];
extern char Kubo_ResNameTable_384[];
extern char Kubo_ResNameTable_385[];
extern char Kubo_ResNameTable_386[];
extern char Kubo_ResNameTable_387[];
extern char Kubo_ResNameTable_388[];
extern char Kubo_ResNameTable_38D[];
extern char Kubo_ResNameTable_390[];
extern char Kubo_ResNameTable_391[];
extern char Kubo_ResNameTable_393[];
extern char Kubo_ResNameTable_394[];
extern char Kubo_ResNameTable_395[];
extern char Kubo_ResNameTable_396[];
extern char Kubo_ResNameTable_397[];
extern char Kubo_ResNameTable_398[];
extern char Kubo_ResNameTable_399[];
extern char Kubo_ResNameTable_39A[];
extern char Kubo_ResNameTable_39B[];
extern char Kubo_ResNameTable_39C[];
extern char Kubo_ResNameTable_39D[];
extern char Kubo_ResNameTable_39E[];
extern char Kubo_ResNameTable_39F[];
extern char Kubo_ResNameTable_3A0[];
extern char Kubo_ResNameTable_3A1[];
extern char Kubo_ResNameTable_3A2[];
extern char Kubo_ResNameTable_3A3[];
extern char Kubo_ResNameTable_3A4[];
extern char Kubo_ResNameTable_3A8[];
extern char Kubo_ResNameTable_3AA[];
extern char Kubo_ResNameTable_3AB[];
extern char Kubo_ResNameTable_3D6[];
extern char Kubo_ResNameTable_3E7[];
extern char Kubo_ViewableTable_00A[];
extern char Kubo_ViewableTable_00B[];
extern char Kubo_ViewableTable_00C[];
extern char Kubo_ViewableTable_00E[];
extern char Kubo_ViewableTable_080[];
extern char Kubo_ViewableTable_081[];
extern char Kubo_ViewableTable_082[];
extern char Kubo_ViewableTable_083[];
extern char Kubo_ViewableTable_084[];
extern char Kubo_ViewableTable_085[];
extern char Kubo_ViewableTable_086[];
extern char Kubo_ViewableTable_087[];
extern char Kubo_ViewableTable_088[];
extern char Kubo_ViewableTable_08D[];
extern char Kubo_ViewableTable_090[];
extern char Kubo_ViewableTable_091[];
extern char Kubo_ViewableTable_093[];
extern char Kubo_ViewableTable_094[];
extern char Kubo_ViewableTable_095[];
extern char Kubo_ViewableTable_096[];
extern char Kubo_ViewableTable_097[];
extern char Kubo_ViewableTable_098[];
extern char Kubo_ViewableTable_099[];
extern char Kubo_ViewableTable_09A[];
extern char Kubo_ViewableTable_09B[];
extern char Kubo_ViewableTable_09C[];
extern char Kubo_ViewableTable_09D[];
extern char Kubo_ViewableTable_09E[];
extern char Kubo_ViewableTable_09F[];
extern char Kubo_ViewableTable_0A0[];
extern char Kubo_ViewableTable_0A1[];
extern char Kubo_ViewableTable_0A2[];
extern char Kubo_ViewableTable_0A3[];
extern char Kubo_ViewableTable_0A4[];
extern char Kubo_ViewableTable_0A8[];
extern char Kubo_ViewableTable_0AA[];
extern char Kubo_ViewableTable_0AB[];
extern char Kubo_ViewableTable_0D6[];
extern char Kubo_ViewableTable_0E7[];
extern char MT_FuncName_PtrTable[];
extern char MtName_PtrTable[];
extern char Yoko_ApFunctionTable_127[];
extern char Yoko_ApFunctionTable_427[];
extern char Yoko_ClassTable_167[];
extern char Yoko_FunctionTable_107[];
extern char Yoko_FunctionTable_407[];
extern char Yoko_MainFuncNameTable_447[];
extern char Yoko_MainFuncTable_147[];
extern char Yoko_ResNameTable_36F[];
extern char Yoko_ResNameTable_370[];
extern char Yoko_ResNameTable_371[];
extern char Yoko_ResNameTable_372[];
extern char Yoko_ResNameTable_373[];
extern char Yoko_ResNameTable_374[];
extern char Yoko_ResNameTable_375[];
extern char Yoko_ResNameTable_376[];
extern char Yoko_ResNameTable_378[];
extern char Yoko_ResNameTable_37A[];
extern char Yoko_ResNameTable_389[];
extern char Yoko_ResNameTable_38A[];
extern char Yoko_ResNameTable_38B[];
extern char Yoko_ResNameTable_38C[];
extern char Yoko_ResNameTable_38E[];
extern char Yoko_ResNameTable_38F[];
extern char Yoko_ResNameTable_392[];
extern char Yoko_ResNameTable_3A7[];
extern char Yoko_ResNameTable_3A9[];
extern char Yoko_ResNameTable_3E0[];
extern char Yoko_ResNameTable_3E1[];
extern char Yoko_ResNameTable_3E2[];
extern char Yoko_ResNameTable_3E3[];
extern char Yoko_ResNames_3E3_Strings[];
extern char Yoko_ViewTable_06F[];
extern char Yoko_ViewTable_070[];
extern char Yoko_ViewTable_071[];
extern char Yoko_ViewTable_072[];
extern char Yoko_ViewTable_073[];
extern char Yoko_ViewTable_074[];
extern char Yoko_ViewTable_075[];
extern char Yoko_ViewTable_076[];
extern char Yoko_ViewTable_078[];
extern char Yoko_ViewTable_07A[];
extern char Yoko_ViewTable_089[];
extern char Yoko_ViewTable_08A[];
extern char Yoko_ViewTable_08B[];
extern char Yoko_ViewTable_08C[];
extern char Yoko_ViewTable_08E[];
extern char Yoko_ViewTable_08F[];
extern char Yoko_ViewTable_092[];
extern char Yoko_ViewTable_0A7[];
extern char Yoko_ViewTable_0A9[];
extern char Yoko_ViewTable_0E0[];
extern char Yoko_ViewTable_0E1[];
extern char Yoko_ViewTable_0E2[];
extern char Yoko_ViewTable_0E3[];
extern char ram_3df10[];
extern char ram_3df14[];

void InitializeYoko(void)
{
	struct objreg reg;

	reg.cls = NAKA_CLASS_Class;
	reg.proc = (void *)ClassProc;
	reg.count = Yoko_ClassCount_167;
	reg.base = Yoko_ClassTable_167;
	RegisterObjectTable(0x167, &reg);
	reg.cls = NAKA_CLASS_ResEvent;
	reg.proc = (void *)ResEventProc;
	reg.count = Yoko_ResEventCount_1C7;
	reg.base = EvtName_PtrTable;
	RegisterObjectTable(0x1c7, &reg);
	reg.cls = NAKA_CLASS_ResMethod;
	reg.proc = (void *)ResMethodProc;
	reg.count = Yoko_ResMethodCount_1E7;
	reg.base = MtName_PtrTable;
	RegisterObjectTable(0x1e7, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x2e;
	reg.base = Yoko_ApFunctionTable_127;
	RegisterObjectTable(0x127, &reg);
	reg.cls = NAKA_CLASS_ApFunction;
	reg.proc = (void *)ApFunctionProc;
	reg.count = 0x2e;
	reg.base = Yoko_ApFunctionTable_427;
	RegisterObjectTable(0x427, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x1;
	reg.base = Yoko_FunctionTable_107;
	RegisterObjectTable(0x107, &reg);
	reg.cls = NAKA_CLASS_Function;
	reg.proc = (void *)FunctionProc;
	reg.count = 0x1;
	reg.base = Yoko_FunctionTable_407;
	RegisterObjectTable(0x407, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x1f;
	reg.base = Yoko_MainFuncTable_147;
	RegisterObjectTable(0x147, &reg);
	reg.cls = NAKA_CLASS_MainFunction;
	reg.proc = (void *)MainFunctionProc;
	reg.count = 0x1f;
	reg.base = Yoko_MainFuncNameTable_447;
	RegisterObjectTable(0x447, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x2b;
	reg.base = Yoko_ViewTable_06F;
	RegisterObjectTable(0x6f, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x2b;
	reg.base = Yoko_ResNameTable_36F;
	RegisterObjectTable(0x36f, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xc;
	reg.base = Yoko_ViewTable_070;
	RegisterObjectTable(0x70, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xc;
	reg.base = Yoko_ResNameTable_370;
	RegisterObjectTable(0x370, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xb;
	reg.base = Yoko_ViewTable_071;
	RegisterObjectTable(0x71, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xb;
	reg.base = Yoko_ResNameTable_371;
	RegisterObjectTable(0x371, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x7;
	reg.base = Yoko_ViewTable_072;
	RegisterObjectTable(0x72, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x7;
	reg.base = Yoko_ResNameTable_372;
	RegisterObjectTable(0x372, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x10;
	reg.base = Yoko_ViewTable_073;
	RegisterObjectTable(0x73, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x10;
	reg.base = Yoko_ResNameTable_373;
	RegisterObjectTable(0x373, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xf;
	reg.base = Yoko_ViewTable_074;
	RegisterObjectTable(0x74, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xf;
	reg.base = Yoko_ResNameTable_374;
	RegisterObjectTable(0x374, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xd;
	reg.base = Yoko_ViewTable_075;
	RegisterObjectTable(0x75, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xd;
	reg.base = Yoko_ResNameTable_375;
	RegisterObjectTable(0x375, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x8;
	reg.base = Yoko_ViewTable_076;
	RegisterObjectTable(0x76, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x8;
	reg.base = Yoko_ResNameTable_376;
	RegisterObjectTable(0x376, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1e;
	reg.base = Yoko_ViewTable_078;
	RegisterObjectTable(0x78, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1e;
	reg.base = Yoko_ResNameTable_378;
	RegisterObjectTable(0x378, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xc;
	reg.base = Yoko_ViewTable_07A;
	RegisterObjectTable(0x7a, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xc;
	reg.base = Yoko_ResNameTable_37A;
	RegisterObjectTable(0x37a, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x5;
	reg.base = Yoko_ViewTable_089;
	RegisterObjectTable(0x89, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x5;
	reg.base = Yoko_ResNameTable_389;
	RegisterObjectTable(0x389, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1;
	reg.base = Yoko_ViewTable_08A;
	RegisterObjectTable(0x8a, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1;
	reg.base = Yoko_ResNameTable_38A;
	RegisterObjectTable(0x38a, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x16;
	reg.base = Yoko_ViewTable_08B;
	RegisterObjectTable(0x8b, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x16;
	reg.base = Yoko_ResNameTable_38B;
	RegisterObjectTable(0x38b, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x1c;
	reg.base = Yoko_ViewTable_08C;
	RegisterObjectTable(0x8c, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x1c;
	reg.base = Yoko_ResNameTable_38C;
	RegisterObjectTable(0x38c, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x5;
	reg.base = Yoko_ViewTable_08E;
	RegisterObjectTable(0x8e, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x5;
	reg.base = Yoko_ResNameTable_38E;
	RegisterObjectTable(0x38e, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x6;
	reg.base = Yoko_ViewTable_08F;
	RegisterObjectTable(0x8f, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x6;
	reg.base = Yoko_ResNameTable_38F;
	RegisterObjectTable(0x38f, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x4;
	reg.base = Yoko_ViewTable_092;
	RegisterObjectTable(0x92, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x4;
	reg.base = Yoko_ResNameTable_392;
	RegisterObjectTable(0x392, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x0;
	reg.base = Yoko_ViewTable_0A7;
	RegisterObjectTable(0xa7, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x0;
	reg.base = Yoko_ResNameTable_3A7;
	RegisterObjectTable(0x3a7, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x6;
	reg.base = Yoko_ViewTable_0A9;
	RegisterObjectTable(0xa9, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x6;
	reg.base = Yoko_ResNameTable_3A9;
	RegisterObjectTable(0x3a9, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0x4;
	reg.base = Yoko_ViewTable_0E0;
	RegisterObjectTable(0xe0, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0x4;
	reg.base = Yoko_ResNameTable_3E0;
	RegisterObjectTable(0x3e0, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xc;
	reg.base = Yoko_ViewTable_0E1;
	RegisterObjectTable(0xe1, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xc;
	reg.base = Yoko_ResNameTable_3E1;
	RegisterObjectTable(0x3e1, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xc;
	reg.base = Yoko_ViewTable_0E2;
	RegisterObjectTable(0xe2, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xc;
	reg.base = Yoko_ResNameTable_3E2;
	RegisterObjectTable(0x3e2, &reg);
	reg.cls = NAKA_CLASS_Viewable;
	reg.proc = (void *)ViewableProc;
	reg.count = 0xc;
	reg.base = Yoko_ViewTable_0E3;
	RegisterObjectTable(0xe3, &reg);
	reg.cls = NAKA_CLASS_ResName;
	reg.proc = (void *)ResNameProc;
	reg.count = 0xc;
	reg.base = Yoko_ResNameTable_3E3;
	RegisterObjectTable(0x3e3, &reg);
	RegisterMode(0xd, NAKA_MAINFUNC_SeqStepModeFunc, TITLE_SQTRSEL, 0x7, Yoko_ResNames_3E3_Strings);
	RegisterMode(0x13, NAKA_MAINFUNC_DemoModeFunc, TITLE_DEMOMENU, 0x7, InitializeYoko_Str_MD_DEMO);
	RegisterTitle(0x6f, NAKA_MAINFUNC_DpSmfTtlFunc, 0x6f0000, 0x7, InitializeYoko_Str_TT_DPSMF);
	RegisterTitle(0x70, NAKA_MAINFUNC_DpDocTtlFunc, 0x700000, 0x7, InitializeYoko_Str_TT_DPDOC);
	RegisterTitle(0x71, NAKA_MAINFUNC_DpPdTtlFunc, 0x710000, 0x7, InitializeYoko_Str_TT_DPPD);
	RegisterTitle(0x72, NAKA_MAINFUNC_DpSmfLyrTtlFunc, 0x720000, 0x7, InitializeYoko_Str_TT_DPSMFLYR);
	RegisterTitle(0x73, NAKA_MAINFUNC_DpMdlySmfTtlFunc, 0x730000, 0x7, InitializeYoko_Str_TT_DPMDLYSMF);
	RegisterTitle(0x74, NAKA_MAINFUNC_DpMdlyDocTtlFunc, 0x740001, 0x7, InitializeYoko_Str_TT_DPMDLYDOC);
	RegisterTitle(0x75, NAKA_MAINFUNC_DpMdlyPdTtlFunc, 0x750000, 0x7, InitializeYoko_Str_TT_DPMDLYPD);
	RegisterTitle(0x76, NMF_DpMdlySmfLyrTtlFunc, 0x760000, 0x7, IniYoko_Str_TT_DPMDLYSMFLYR);
	RegisterTitle(0x78, NAKA_MAINFUNC_DkMdlyPlyTtlFunc, 0x780000, 0x7, InitializeYoko_Str_TT_DKMDLYPLY);
	RegisterTitle(0x7a, NAKA_MAINFUNC_SqMdlyPlyTtlFunc, 0x7a0000, 0x7, InitializeYoko_Str_TT_SQMDLYPLY);
	RegisterTitle(0x89, NAKA_MAINFUNC_SqTrSelTtlFunc, 0x890000, 0x7, InitializeYoko_Str_TT_SQTRSEL);
	RegisterTitle(0x8a, NAKA_MAINFUNC_SqStepTtlFunc, 0x8a0000, 0x7, InitializeYoko_Str_TT_SQSTEP);
	RegisterTitle(0x8b, NAKA_MAINFUNC_SqTrAsTtlFunc, 0x8b0000, 0x7, InitializeYoko_Str_TT_SQTRAS);
	RegisterTitle(0x8c, NAKA_MAINFUNC_SqTrAsPsTtlFunc, 0x8c0000, 0x7, InitializeYoko_Str_TT_SQTRASPS);
	RegisterTitle(0x8e, NAKA_MAINFUNC_SqSngSelTtlFunc, 0x8e0000, 0x7, InitializeYoko_Str_TT_SQSNGSEL);
	RegisterTitle(0x8f, NAKA_MAINFUNC_SqSngNameTtlFunc, 0x8f0000, 0x7, InitializeYoko_Str_TT_SQSNGNAME);
	RegisterTitle(0x92, NAKA_MAINFUNC_SqAftSetTtlFunc, 0x920000, 0x7, InitializeYoko_Str_TT_SQAFTSET);
	RegisterTitle(0xa7, NAKA_MAINFUNC_SqSngNameTtlFunc, 0x8f0000, 0x7, IniYoko_Str_TT_SQEASYNAME);
	RegisterTitle(0xa9, NAKA_APFUNC_DefaultFunction, 0xa90000, 0x7, InitializeYoko_Str_TT_SQSTEPBAL);
	RegisterTitle(0xe0, NAKA_MAINFUNC_DemoMenuTtlFunc, NAKA_VIEW_DemoMenu, 0x7, InitializeYoko_Str_TT_DEMOMENU);
	RegisterTitle(0xe1, NAKA_MAINFUNC_DemoStyleTtlFunc, NAKA_VIEW_DemoStyle, 0x7, InitializeYoko_Str_TT_DEMOSTYLE);
	RegisterTitle(0xe2, NAKA_MAINFUNC_DemoSoundTtlFunc, NAKA_VIEW_DemoSound, 0x7, InitializeYoko_Str_TT_DEMOSOUND);
	RegisterTitle(0xe3, NAKA_MAINFUNC_DemoRhyTtlFunc, NAKA_VIEW_DemoRhy, 0x7, InitializeYoko_Str_TT_DEMORHY);
}

