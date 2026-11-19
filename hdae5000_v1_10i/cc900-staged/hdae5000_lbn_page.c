/* hdae5000_v1_10i: the functions of hdae5000/cc900/hdae5000_lbn_page.c that V4.23 reproduces in HD-AE5000 v1.10i with the tree's own object ids and ram_ addresses (port_built.py).
   Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv); from hdae5000_lbn_page.c.
   cc900-options: -Xr
   cc900-module: HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   cc900-data: HDAE5000_Lbn_StepDigit 1 = HDAE5000_Lbn_StepDigit_CaseTable
   cc900-data: HDAE5000_LBNPage1SwCatch 1 = HDAE5000_LBNPage1SwCatch_CaseTable
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

struct TypeSel { unsigned int mask; unsigned char flag[10]; };

/* ---- this module (calr) ---- */
extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_TypeSel_Init(void *rec, unsigned int mask, unsigned char *tmpl, int n);
extern void HDAE5000_PartList_Build(long obj, int dir, int song, unsigned int mask);
extern void HDAE5000_Lbn_TypeDigit(long obj, int digit);
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step);

/* ---- other modules (call) ---- */
extern unsigned int HDAE5000_Song_PartMask(unsigned int dir, unsigned int song);

/* ---- RAM ---- */
extern struct TypeSel HDAE5000_RAM_SaveOptions;
extern unsigned int HDAE5000_RAM_CurDir;
extern unsigned int HDAE5000_RAM_CurSong;
extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;
/* the same three cells as int: HDAE5000_RAM_LbnDigitPos, _LbnDir, _LbnSong */
extern int ram_22aa14;
extern int ram_22aa16;
extern int ram_22aa18;

/* ---- ROM ---- */
extern char HDAE5000_Str_LBNS[];
extern unsigned char HDAE5000_TypeSel_TemplateBlank[];

/* ---- HDAE5000_Lbn_StepDigit ------------------------------------------------------------------------------ */

/* a local copy of dir */
void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step)
{
    int m;
    int d;

    d = dir;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        return;
    case 1:
        d += step * 100;
        if (d >= 100)
            d = 100;
        else if (d <= 0)
            d = 0;
        break;
    case 2:
        d += step * 10;
        if (d >= 120)
            d = 120;
        else if (d <= 1)
            d = 0;
        break;
    case 3:
        d += step;
        if (d > 120)
            d = 120;
        else if (d <= 0)
            d = 1;
        break;
    case 4:
        song += step * 10;
        if (song >= 10)
            song = 10;
        else if (song <= 0)
            song = 0;
        break;
    case 5:
        song += step;
        if (song > 16)
            song = 16;
        else if (song <= 0)
            song = 1;
    }
    HDAE5000_RAM_LbnDir = d;
    HDAE5000_RAM_LbnSong = song;
    if (HDAE5000_RAM_LbnDigitPos == 5) {
        HDAE5000_RAM_CurDir = HDAE5000_RAM_LbnDir - 1;
        HDAE5000_RAM_CurSong = HDAE5000_RAM_LbnSong - 1;
        if ((m = HDAE5000_Song_PartMask(HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong)) != 0xffff) {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, m, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, HDAE5000_RAM_CurDir, HDAE5000_RAM_CurSong, m);
        } else {
            HDAE5000_TypeSel_Init(&HDAE5000_RAM_SaveOptions, 0, HDAE5000_TypeSel_TemplateBlank, 2);
            HDAE5000_PartList_Build(OBJ_LBN_OPTION, -1, -1, 0xffff);
        }
    }
    HDAE5000_Lbn_ShowEntry(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, 1);
}

/* the copy as an initialiser */

/* the unused third parameter reused as the copy */

/* dir unsigned, the int copy being the conversion */

/* ---- HDAE5000_LBNPage1SwCatch ---------------------------------------------------------------------------- */

/* int cells; unsigned s by if / else */
long HDAE5000_LBNPage1SwCatch(long obj, long ev, long arg)
{
    unsigned int s;

    switch (ev) {
    case EVT_ARE_YOU_CLASS_PROC:
        return 1;
    case EVT_DRAW:
        CALLV(ROOT->InheritedProc)(obj, ev, arg);
        CALLV(ROOT->SendEvent)(obj, EVT_PARA_DRAW, (long)HDAE5000_Str_LBNS);
        return 0;
    case EVT_SW_IN:
        switch (CALLR(unsigned long, ROOT->SendEvent)(0x02600024L, EVT_MAKE_EDIT_SW_ID, arg)) {
        case 12:
            HDAE5000_Lbn_ShowEntry(0, 0, 6, 1);
            break;
        case 5:
        case 6:
        case 7:
            if ((arg & 0x80) == 0)
                s = 1;
            else
                s = 0xffff;
            HDAE5000_Lbn_StepDigit(ram_22aa16, ram_22aa18, ram_22aa14, s);
            break;
        case 0:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 0);
            else
                HDAE5000_Lbn_TypeDigit(obj, 1);
            break;
        case 1:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 2);
            else
                HDAE5000_Lbn_TypeDigit(obj, 3);
            break;
        case 2:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 4);
            else
                HDAE5000_Lbn_TypeDigit(obj, 5);
            break;
        case 3:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 6);
            else
                HDAE5000_Lbn_TypeDigit(obj, 7);
            break;
        case 4:
            if (arg & 0x80)
                HDAE5000_Lbn_TypeDigit(obj, 8);
            else
                HDAE5000_Lbn_TypeDigit(obj, 9);
        }
        break;
    }
    return CALLR(long, ROOT->InheritedProc)(obj, ev, arg);
}

/* int cells; int s by if / else */

/* int cells; unsigned s passed through a cast */

/* int cells; the conditional expression with 0xffff */

/* the unsigned cells, each cast to int; unsigned s */
