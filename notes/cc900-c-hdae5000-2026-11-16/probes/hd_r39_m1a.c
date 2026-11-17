/* lane_hd round 39, helper h_m1: HDAE5000_DirList_BuildPage and HDAE5000_FlsList_BuildPage, from hd_r13_nb.c, in ROM
   address order, with variants.  No calr in either, so no cc900-module list.
   cc900-options: -Xr
   What runs 2026-11-16-74 / -83 left, and the change for each:
   - the row offset, `ldw wa,21; muls xwa,iz` (DirList) / `mul xwa,iz` (FlsList): the constant through a comma
     expression (run 2026-11-17-3-hd-r36: SongScreen_Refresh's `(0, 30) * i + &text[..]` for the signed loop,
     FlsScreen_Refresh's `&rows[(k = 37, k * i) + ..]` with a local k for the unsigned one);
   - the name's address: the ROM calls DirName_Address / FlsRecord_Address BEFORE it pushes the length 16 and then
     pushes XHL; as an argument the call came after `pushw 0x10`.  A local `rec` assigned from the call in a
     statement of its own (as in the two matched Refresh functions; it gets no stack slot);
   - DirList only: DirName_Address's argument is `ld wa,(DirPageBase); add wa,iz` in the ROM; run 83 gave
     `ld wa,iz; add wa,(DirPageBase)` for `HDAE5000_RAM_DirPageBase + i` with an unsigned base (the int i is the
     converted operand, evaluated first).  The base is declared `int` here, so that base + i has no conversion; the
     SPrintf argument i + base + 1 keeps its order (`ld wa,iz; add wa,(base); inc 1,wa`);
   - FlsList: the two ROM labels over 31 characters are written ram_<hex> (as hdae5000_fls_refresh.c does); run 83
     could not translate that function and run 74 pushed the format as `ld xwa,imm; push xwa`.
   Variants:
     DirListBP_u: the int sum converted at the call, `(unsigned int)(base + i)` (the callee's parameter is unsigned;
       the main form passes the int to an unprototyped declaration, no conversion);
     DirListBP_k: the row length through a local, `(k = 21, k * i)`;
     DirListBP_t: the row address as pointer + product, `&text[0] + (0, 21) * i`;
     FlsListBP_z: the row length as `(0, 21) * i` inside the index, no local;
     FlsListBP_o: k declared before i.
   cc900-name: DirListBP_u=HDAE5000_DirList_BuildPage
   cc900-name: DirListBP_k=HDAE5000_DirList_BuildPage
   cc900-name: DirListBP_t=HDAE5000_DirList_BuildPage
   cc900-name: FlsListBP_z=HDAE5000_FlsList_BuildPage
   cc900-name: FlsListBP_o=HDAE5000_FlsList_BuildPage
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
void DirListBP_u(long obj)
{
    char num[22];
    int i;
    const void *rec;

    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[0], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[0], num, 3);
        rec = HDAE5000_DirName_Address((unsigned int)(HDAE5000_RAM_DirPageBase + i));
        HDAE5000_MemCopy((0, 21) * i + &HDAE5000_RAM_DirListText[4], rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

/* the row length through a local k */
void DirListBP_k(long obj)
{
    char num[22];
    int i;
    const void *rec;
    int k;

    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy((k = 21, k * i) + &HDAE5000_RAM_DirListText[0], HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy((k = 21, k * i) + &HDAE5000_RAM_DirListText[0], num, 3);
        rec = HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i);
        HDAE5000_MemCopy((k = 21, k * i) + &HDAE5000_RAM_DirListText[4], rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

/* the row address as pointer + product */
void DirListBP_t(long obj)
{
    char num[22];
    int i;
    const void *rec;

    HDAE5000_MemFill(HDAE5000_RAM_DirListText, 0, 0x1f9);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[0] + (0, 21) * i, HDAE5000_Str_Chr2020203A2020, 21);
        HDAE5000_SPrintf(num, HDAE5000_Fmt_3_3d, i + HDAE5000_RAM_DirPageBase + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[0] + (0, 21) * i, num, 3);
        rec = HDAE5000_DirName_Address(HDAE5000_RAM_DirPageBase + i);
        HDAE5000_MemCopy(&HDAE5000_RAM_DirListText[4] + (0, 21) * i, rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(obj, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_DirListText));
    CALLV(ROOT->ApPostEvent)(obj, EVT_PARA_DRAW, -1L);
}

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
void FlsListBP_z(void)
{
    char num[22];
    unsigned int i;
    const void *rec;

    HDAE5000_MemFill(HDAE5000_RAM_FlsListText, 0, 0x781);
    for (i = 0; i < 24; i++) {
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(0, 21) * i], ram_2e2e60, 21);
        HDAE5000_SPrintf(num, ram_2e2e76, HDAE5000_RAM_FlsPageBase + i + 1);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(0, 21) * i], num, HDAE5000_StrLen(num));
        rec = HDAE5000_FlsRecord_Address(HDAE5000_RAM_FlsPageBase + i);
        HDAE5000_MemCopy(&HDAE5000_RAM_FlsListText[(0, 21) * i + 4], rec, 16);
    }
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_HDAE_SET_STR_ADR, WRAP(HDAE5000_RAM_FlsListText));
    CALLV(ROOT->ApPostEvent)(OBJ_SEL_FLS, EVT_PARA_DRAW, -1L);
}

/* k declared before i */
void FlsListBP_o(void)
{
    char num[22];
    unsigned int k;
    unsigned int i;
    const void *rec;

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
