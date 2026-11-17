/* hd_r39_m2c.c (helper h_m2, lane_hd round 39): HDAE5000_Lbn_StepDigit and HDAE5000_LBNPage1SwCatch
   (hdae5000_hd_driver.s; ROM address order; the second calls the first by calr), each with variants.
   cc900-options: -Xr
   cc900-module: HDAE5000_Lbn_ShowEntry HDAE5000_TypeSel_Init HDAE5000_PartList_Build
   cc900-module: HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   cc900-data: HDAE5000_Lbn_StepDigit 1 = HDAE5000_Lbn_StepDigit_CaseTable
   cc900-data: HDAE5000_LBNPage1SwCatch 1 = HDAE5000_LBNPage1SwCatch_CaseTable
   cc900-name: LbnStep_i=HDAE5000_Lbn_StepDigit
   cc900-name: LbnStep_p=HDAE5000_Lbn_StepDigit
   cc900-name: LbnStep_u=HDAE5000_Lbn_StepDigit
   cc900-name: LBNP1_e=HDAE5000_LBNPage1SwCatch
   cc900-name: LBNP1_f=HDAE5000_LBNPage1SwCatch
   cc900-name: LBNP1_g=HDAE5000_LBNPage1SwCatch
   cc900-name: LBNP1_h=HDAE5000_LBNPage1SwCatch
   (The two cc900-data lines name the tree's tables for the two labels, as hd_r36_fix4l.c did for the second;
   the variants have none, as there.)

   Lbn_StepDigit (run 2026-11-16-116-hd-r27c, hd_r27_c1.c; +4): ONE difference, and all the others follow from
   it.  The ROM copies dir out of WA at entry (`ld de,wa`, after the stacked step is loaded into HL) and then has
   WA as its work register: the switch value, the step products, and DE compared / clamped / stored as the
   directory.  V4.23 left dir in WA and worked in DE.  With the registers exchanged the two listings read the same
   instruction for instruction (the switch and its table, the five cases, the stores, the PartMask part with m in
   IZ, the calls).  A parameter copied at entry is a local copy (the brief's rule, run 48); the third parameter
   is never read, which leaves DE free for it.
   - HDAE5000_Lbn_StepDigit: `int d; d = dir;`, d used in place of dir;
   - LbnStep_i: the copy as an initialiser;
   - LbnStep_p: the unused third parameter reused, `pos = dir;`;
   - LbnStep_u: dir an unsigned parameter, the int copy being the conversion (the compares are signed).

   LBNPage1SwCatch (run 2026-11-17-3-hd-r36, hd_r36_fix4l.c; +191): ONE place, the call of Lbn_StepDigit for edit
   switches 5-7.  The ROM: bit test, 1 or 0xffff into WA, `pushw wa` AT ONCE, then the three RAM words straight
   into WA / BC / DE.  Run 36: int s went to HL and was pushed after the three loads (main, _b); unsigned s went
   to WA as in the ROM, but the three words were still loaded first (the directory into HL, moved to WA after the
   push: _c); the conditional expression was a late select (_d).  So V4.23 evaluated the three register arguments
   BEFORE the stacked one.  The same three words passed to Lbn_ShowEntry after `pushw 1` are loaded late, and
   there no type changes; here they are unsigned words passed to int parameters: a conversion on an argument
   makes V4.23 evaluate it early (the brief, runs 57-66).  So the forms pass them with no conversion, through int
   names for the same three cells (ram_22aa5e = HDAE5000_RAM_LbnDir, ram_22aa60 = _LbnSong, ram_22aa5c =
   _LbnDigitPos):
   - HDAE5000_LBNPage1SwCatch: int cells, `unsigned int s` set to 1 / 0xffff by if / else (run 36's _c otherwise);
   - LBNP1_e: int cells, `int s` set to 1 / -1;
   - LBNP1_f: int cells, unsigned s passed through a cast, (int)s;
   - LBNP1_g: int cells, the conditional expression with 0xffff;
   - LBNP1_h: the unsigned cells as before, each cast to int explicitly, unsigned s (in case the explicit form is
     treated differently from the implicit one).
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
extern int ram_22aa5c;
extern int ram_22aa5e;
extern int ram_22aa60;

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
void LbnStep_i(int dir, int song, int pos, int step)
{
    int m;
    int d = dir;

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

/* the unused third parameter reused as the copy */
void LbnStep_p(int dir, int song, int pos, int step)
{
    int m;

    pos = dir;
    switch (HDAE5000_RAM_LbnDigitPos) {
    case 0:
        return;
    case 1:
        pos += step * 100;
        if (pos >= 100)
            pos = 100;
        else if (pos <= 0)
            pos = 0;
        break;
    case 2:
        pos += step * 10;
        if (pos >= 120)
            pos = 120;
        else if (pos <= 1)
            pos = 0;
        break;
    case 3:
        pos += step;
        if (pos > 120)
            pos = 120;
        else if (pos <= 0)
            pos = 1;
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
    HDAE5000_RAM_LbnDir = pos;
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

/* dir unsigned, the int copy being the conversion */
void LbnStep_u(unsigned int dir, int song, int pos, int step)
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
            HDAE5000_Lbn_StepDigit(ram_22aa5e, ram_22aa60, ram_22aa5c, s);
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
long LBNP1_e(long obj, long ev, long arg)
{
    int s;

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
                s = -1;
            HDAE5000_Lbn_StepDigit(ram_22aa5e, ram_22aa60, ram_22aa5c, s);
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

/* int cells; unsigned s passed through a cast */
long LBNP1_f(long obj, long ev, long arg)
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
            HDAE5000_Lbn_StepDigit(ram_22aa5e, ram_22aa60, ram_22aa5c, (int)s);
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

/* int cells; the conditional expression with 0xffff */
long LBNP1_g(long obj, long ev, long arg)
{
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
            HDAE5000_Lbn_StepDigit(ram_22aa5e, ram_22aa60, ram_22aa5c, (arg & 0x80) == 0 ? 1 : 0xffff);
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

/* the unsigned cells, each cast to int; unsigned s */
long LBNP1_h(long obj, long ev, long arg)
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
            HDAE5000_Lbn_StepDigit((int)HDAE5000_RAM_LbnDir, (int)HDAE5000_RAM_LbnSong,
                                   (int)HDAE5000_RAM_LbnDigitPos, s);
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
