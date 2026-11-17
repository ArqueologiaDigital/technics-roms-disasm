/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m272.c (2026-11-16-122-p6-r24-staged)
   sha256 088667ef9921df9def8d2f926bfca400689be92e45aeaab97bbc728e4fa5f2cc (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define NAKA_CLASS_SupportClass 0x1600005L
#define NAKA_CLASS_Mode         0x1600006L
#define NAKA_CLASS_Title        0x1600007L
#define NAKA_CLASS_Viewable     0x1600010L
struct objent { long id; long a; int b; long c; };
struct objreg { long cls; void *proc; int count; void *base; };
struct moderec { int w[7]; };
struct titlerec { int w[11]; };
extern struct objent OBJECT_REGISTRY[];
extern int ram_2bc12;
extern struct moderec ram_328fc[];
extern struct titlerec ram_32abc[];
extern long ram_276d2[];
extern long ram_27ad2[];
extern struct moderec NakaMode_InitRecord;
extern struct titlerec Title_RecordTemplate;
extern char SupportClass_PropTypeRecords[];
extern long SupportClassProc(long, long, long);
extern long ModeProc(long, long, long);
extern long TitleProc(long, long, long);
extern long ViewableProc(long, long, long);
extern void RegisterObjectTable(unsigned int, struct objreg *);
extern void SetCurrentTarget(long);
extern void InitializeMurai(void);
extern void InitializeToshi(void);
extern void InitializeEast(void);
extern void InitializeSuna(void);
extern void InitializeCheap(void);
extern void InitializeScoop(void);
extern void InitializeYoko(void);
extern void InitializeKubo(void);
extern void InitializeHama(void);
extern void InitializeKSS(void);
extern void InitializeNaka(void);
extern void InitializeUser12(void);
extern void InitializeUser13(void);
extern void InitializeUser14(void);
extern void InitializeUser15(void);
extern void InitializeUser16(void);
extern void InitializeUser17(void);
extern void InitializeUser18(void);
extern void InitializeUser19(void);
extern void InitializeUser20(void);
extern void InitializeUser21(void);
extern void InitializeUser22(void);
extern void InitializeUser23(void);
extern void InitializeUser24(void);
extern void InitializeUser25(void);
extern void InitializeUser26(void);
extern void InitializeUser27(void);
extern void InitializeUser28(void);
extern void InitializeUser29(void);
extern void InitializeUser30(void);
extern void InitializeUser31(void);
extern void InitializeRoot(void);
void InitializeObjectTable(void)
{
    struct objreg reg;
    unsigned int i;

    ram_2bc12 = 0;
    for (i = 0; i < 1120; i++) {
        OBJECT_REGISTRY[i].id = -1;
        OBJECT_REGISTRY[i].a = 0;
        OBJECT_REGISTRY[i].b = 0;
        OBJECT_REGISTRY[i].c = 0;
    }
    for (i = 0; i < 32; i++)
        ram_328fc[i] = NakaMode_InitRecord;
    for (i = 0; i < 256; i++)
        ram_32abc[i] = Title_RecordTemplate;
    reg.cls = NAKA_CLASS_SupportClass;
    reg.proc = (void *)SupportClassProc;
    reg.count = 0x37;
    reg.base = SupportClass_PropTypeRecords;
    RegisterObjectTable(0x260, &reg);
    reg.cls = NAKA_CLASS_Mode;
    reg.proc = (void *)ModeProc;
    reg.count = 0x20;
    reg.base = ram_328fc;
    RegisterObjectTable(0x180, &reg);
    reg.cls = NAKA_CLASS_Title;
    reg.proc = (void *)TitleProc;
    reg.count = 0x100;
    reg.base = ram_32abc;
    RegisterObjectTable(0x1a0, &reg);
    for (i = 0; i < 256; i++) {
        reg.cls = NAKA_CLASS_Viewable;
        reg.proc = (void *)ViewableProc;
        reg.count = 0;
        reg.base = (void *)(ram_276d2 + i);
        RegisterObjectTable(i, &reg);
        reg.base = (void *)(ram_27ad2 + i);
        RegisterObjectTable(i + 0x300, &reg);
    }
    SetCurrentTarget(0);
    InitializeMurai();
    InitializeToshi();
    InitializeEast();
    InitializeSuna();
    InitializeCheap();
    InitializeScoop();
    InitializeYoko();
    InitializeKubo();
    InitializeHama();
    InitializeKSS();
    InitializeNaka();
    InitializeUser12();
    InitializeUser13();
    InitializeUser14();
    InitializeUser15();
    InitializeUser16();
    InitializeUser17();
    InitializeUser18();
    InitializeUser19();
    InitializeUser20();
    InitializeUser21();
    InitializeUser22();
    InitializeUser23();
    InitializeUser24();
    InitializeUser25();
    InitializeUser26();
    InitializeUser27();
    InitializeUser28();
    InitializeUser29();
    InitializeUser30();
    InitializeUser31();
    InitializeRoot();
}
