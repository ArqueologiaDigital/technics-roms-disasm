/* lane_hd round 13, helper h_near2, form b: hd_r13_nb.c's functions (same names) with two more spellings of the row
   offset that V4.23 must compile as `ld wa,21; muls/mul xwa,iz` (the constant loaded, then a register multiply):
     HDAE5000_DirList_BuildPage / HDAE5000_FlsList_BuildPage: the row length as an address constant on the left,
       ((int)(char *)&((struct Row21 *)0)[1]) * i (offsetof style), in case V4.23 folds it after choosing the
       operand order;
     DirListBP_x / FlsListBP_x: the text through a pointer to 21-byte arrays, ((char (*)[21])Text)[i], whose row
       scaling may differ from run 49's declared [24][21] array.
   Everything else as in form a (DirName_Address(base + i), the formats as char arrays).  Options: -Xr.
   cc900-name: DirListBP_x=HDAE5000_DirList_BuildPage
   cc900-name: FlsListBP_x=HDAE5000_FlsList_BuildPage
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

/* the row length as an address constant (the size of one row struct, offsetof style), not a literal */
struct Row21 { char t[21]; };
#define ROWLEN ((int)(char *)&((struct Row21 *)0)[1])
#define UROWLEN ((unsigned int)(char *)&((struct Row21 *)0)[1])
/* the text through a pointer to 21-byte arrays (variants _x) */
#define DIRX ((char (*)[21])HDAE5000_RAM_DirListText)
#define FLSX ((char (*)[21])HDAE5000_RAM_FlsListText)

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + ROWLEN * i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(HDAE5000_RAM_DirListText + ROWLEN * i, num, 3);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + ROWLEN * i,
                         HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

void DirListBP_x(long obj)
{
    char num[22];
    int i;
    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(DIRX[i], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, FMT_DIR, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(DIRX[i], num, 3);
        HDAE5000_MemCopy(&DIRX[i][4],
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
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[UROWLEN * i], HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[UROWLEN * i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[UROWLEN * i + 4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

void FlsListBP_x(void)
{
    char num[22];
    unsigned int i;
    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(FLSX[i], HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage, 21);
        HDAE5000_SPrintf(num, FMT_FLS, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(FLSX[i], num, HDAE5000_StrLen(num));
        HDAE5000_MemCopy(&FLSX[i][4],
                         HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i), 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}
