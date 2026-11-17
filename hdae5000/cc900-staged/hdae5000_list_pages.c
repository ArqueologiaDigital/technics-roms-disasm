/* The directory and file-list pages' text builders.
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hd_r39_m1a.c.
   cc900-options: -Xr
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern void *__cdecl HDAE5000_MemCopy(void *, const void *, unsigned int);
extern void *__cdecl HDAE5000_MemFill(void *, int, unsigned int);
extern int __cdecl HDAE5000_SPrintf(char *, char *, ...);
extern unsigned int __cdecl HDAE5000_StrLen(const char *);
/* no prototype: the main form passes the int sum as it is */
extern unsigned char *HDAE5000_DirName_Address();
extern unsigned char *HDAE5000_FlsRecord_Address(unsigned int fls);

/* an array read as an lvalue member at offset 0 (hd_r9_b2.c: gives the ROM's `lda xwa,(sym); ld xR,xwa`) */
struct Wrap { char c[2]; };
#define WRAP(x) (((struct Wrap *)(x))->c)

extern char HDAE5000_RAM_DirListText[];
extern char HDAE5000_RAM_FlsListText[];
extern int HDAE5000_RAM_DirPageBase;
extern unsigned int HDAE5000_RAM_FlsPageBase;
extern char HDAE5000_Str_Chr2020203A2020[];
extern char HDAE5000_Fmt_3_3d[];
extern char ram_2e2e60[];   /* HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage */
extern char ram_2e2e76[];   /* HDAE5000_Fmt_3_3d_FlsList_BuildPage, "%3.3d" */

void HDAE5000_DirList_BuildPage(long obj)
{
    char num[22];
    int i;
    const void *rec;

    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[0], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[0], num, 3);
        rec = HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i);
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[4], rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

/* the argument converted to the callee's unsigned parameter type */

/* the row length through a local k */

/* the row address as pointer + product */

void HDAE5000_FlsList_BuildPage(void)
{
    char num[22];
    unsigned int i;
    const void *rec;
    unsigned int k;

    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(k = 21, k * i)], ram_2e2e60, 21);
        HDAE5000_SPrintf(num, ram_2e2e76, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(k = 21, k * i)], num, HDAE5000_StrLen(num));
        rec = HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(k = 21, k * i) + 4], rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

/* the row length as `(0, 21) * i`, no local */

/* k declared before i */
