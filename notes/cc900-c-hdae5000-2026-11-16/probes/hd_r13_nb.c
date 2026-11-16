/* lane_hd round 13, helper h_near2, form a: HDAE5000_DirList_BuildPage and HDAE5000_FlsList_BuildPage (no calr in
   either; they share no module, but neither calls the other, so one file changes nothing), from hd_r9_b2.c /
   hd_r9_b2b.c, in ROM address order, with variants under cc900-name aliases.  Options: -Xr.
   Run 2026-11-16-64 (both at +31 / +29 only because the jr ge / nc grew; the first real difference follows):
   - the row offset.  The ROM loads the row length into WA and multiplies by the loop variable's register,
     `ldw wa,21; muls xwa,iz` (DirList, signed) / `mul xwa,iz` (FlsList, unsigned); every spelling so far (21 * i,
     i * 21, (char)21 * i, (int)sizeof(Row) * i, a [24][21] array, a register i) gave the immediate form
     `ld wa,iz; muls wa,21`: V4.23 puts a literal on the right.  No V4.23 listing of any run has a constant loaded
     into WA before a register multiply, so the shape needs a right operand that V4.23 does not treat as a plain
     variable it may swap with the literal.  The ROM has the same shape in FlsScreen_Refresh (37) and
     SongScreen_Refresh (30), so it is one idiom.  Tried here:
       HDAE5000_DirList_BuildPage / HDAE5000_FlsList_BuildPage: a no-op cast on the variable, 21 * (int)i
         (21 * (unsigned int)i), so that the right operand is an expression node, not the variable;
       DirListBP_s / FlsListBP_s: the text as an array of 21-byte row structs, rows[i].t (V4.23's scaling of a
         struct index, which may be a different code path from an explicit multiply);
       DirListBP_p / FlsListBP_p: unary plus on the variable, 21 * +i.
   - the SPrintf formats (both): the ROM pushes them as `pushw Fmt@hi16 / pushw Fmt@lo16`; run 64's constant pointer
     gave `ld xwa,imm; push xwa`.  Now the tree's char arrays with a plain char * format parameter (V4.23's pushw
     pair for an array symbol that needs no conversion, hd_r9_nl's lyrics module);
   - DirList: DirName_Address's argument is base + i in the ROM (`ld wa,(DirPageBase); add wa,iz`); run 64 had
     i + base.  The SPrintf argument stays i + base + 1 (`ld wa,iz; add wa,(base); inc 1,wa`), FlsList's base + i + 1.
   cc900-name: DirListBP_s=HDAE5000_DirList_BuildPage
   cc900-name: DirListBP_p=HDAE5000_DirList_BuildPage
   cc900-name: FlsListBP_s=HDAE5000_FlsList_BuildPage
   cc900-name: FlsListBP_p=HDAE5000_FlsList_BuildPage
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
extern unsigned char *HDAE5000_DirName_Address(unsigned int dir);
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);

/* an array read as an lvalue member at offset 0 (hd_r9_b2.c: gives the ROM's `lda xwa,(sym); ld xR,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_FlsListText[];
extern unsigned int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage[];
/* the "%3.3d" formats, pushed as `pushw sym@hi16 / pushw sym@lo16`: V4.23 pushes an array symbol that way when the
   argument needs no conversion (SPrintf's format is a plain char *; run 64's (const char *)0x2e23d2L constant gave
   `ld xwa,imm; push xwa`, which the ROM does not have) */
extern char HDAE5000_Fmt_3_3d[];
extern char HDAE5000_Fmt_3_3d_FlsList_BuildPage[];
#define FMT_DIR HDAE5000_Fmt_3_3d
#define FMT_FLS HDAE5000_Fmt_3_3d_FlsList_BuildPage

/* the same text as rows (variants _s) */
struct Row21 { char t[21]; };
#define DIRROWS ((struct Row21 *)HDAE5000_RAM_DirListText)
#define FLSROWS ((struct Row21 *)HDAE5000_RAM_FlsListText)

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * (int)i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * (int)i, num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + 21 * (int)i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void DirListBP_s(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(DIRROWS[i].t, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(DIRROWS[i].t, num, 3);
        HDAE5000_MemCopy(&DIRROWS[i].t[4], HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void DirListBP_p(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * +i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + 21 * +i, num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + 21 * +i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void HDAE5000_FlsList_BuildPage(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * (unsigned int)i],
                         HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * (unsigned int)i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * (unsigned int)i + 4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

void FlsListBP_s(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(FLSROWS[i].t, HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(FLSROWS[i].t, num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&FLSROWS[i].t[4], HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

void FlsListBP_p(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * +i], HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * +i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[21 * +i + 4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}
