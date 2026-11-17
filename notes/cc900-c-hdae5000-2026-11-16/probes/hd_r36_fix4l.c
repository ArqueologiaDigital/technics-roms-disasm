/* lane_hd round 36, helper h_fix4: HDAE5000_LBNPage1SwCatch (hdae5000_hd_driver.s), hd_r27_c1.c's function with
   the one place where run 2026-11-16-116-hd-r27c departed from the ROM corrected.
   cc900-options: -Xr
   cc900-module: HDAE5000_Lbn_ShowEntry HDAE5000_Lbn_StepDigit HDAE5000_Lbn_TypeDigit
   cc900-data: HDAE5000_LBNPage1SwCatch 1 = HDAE5000_LBNPage1SwCatch_CaseTable
   cc900-name: LBNP1_b=HDAE5000_LBNPage1SwCatch
   cc900-name: LBNP1_c=HDAE5000_LBNPage1SwCatch
   cc900-name: LBNP1_d=HDAE5000_LBNPage1SwCatch
   The departure (edit switches 5-7, the step of Lbn_StepDigit): the ROM branches on bit 7 of arg, loads WA with 1
   or with 0xffff as a WORD, pushes it, and only then loads the three register arguments from RAM.  V4.23 compiled
   run 116's conditional expression as a byte select (the second value preloaded into C, overwritten after the
   test, then widened) and loaded the three globals into spare registers before it.  The matched
   AttenHDFormatSwCatch (hdae5000/cc900/hdae5000_drv_screens6.c) had the same departure and was solved by an
   if / else into a local that dies at the call: the main form here.
   Everything else of run 116 reads as the ROM (the event compares, the DRAW body, the unsigned switch on the
   edit-switch number with its table, the five digit cases with two calls each, the common exit); the +37 first
   difference is only the exit branch's distance, which follows from the step code's length.
   Forms:
   - HDAE5000_LBNPage1SwCatch: `if ((arg & 0x80) == 0) s = 1; else s = -1;` (the ROM: jr nz to the 0xffff load,
     the 1 first);
   - LBNP1_b: the same with the test the other way round (`if (arg & 0x80) s = -1; else s = 1;`), in case V4.23
     lays the blocks out by the branch and not by the source;
   - LBNP1_c: as the main form with `unsigned int s` and 0xffff;
   - LBNP1_d: run 116's conditional expression with 0xffff for -1 (not a char value: no byte select possible).
*/
#include "hdae_ws.h"
#include "hdae_ids.h"

extern int HDAE5000_Lbn_ShowEntry(unsigned int dir, unsigned int song, unsigned int pos, int draw);
extern void HDAE5000_Lbn_TypeDigit(long obj, int digit);
extern void HDAE5000_Lbn_StepDigit(int dir, int song, int pos, int step);

extern unsigned int HDAE5000_RAM_LbnDigitPos;
extern unsigned int HDAE5000_RAM_LbnDir;
extern unsigned int HDAE5000_RAM_LbnSong;

extern char HDAE5000_Str_LBNS[];

long HDAE5000_LBNPage1SwCatch(long obj, long ev, long arg)
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
            HDAE5000_Lbn_StepDigit(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, s);
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

long LBNP1_b(long obj, long ev, long arg)
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
            if (arg & 0x80)
                s = -1;
            else
                s = 1;
            HDAE5000_Lbn_StepDigit(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, s);
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

long LBNP1_c(long obj, long ev, long arg)
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
            HDAE5000_Lbn_StepDigit(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos, s);
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

long LBNP1_d(long obj, long ev, long arg)
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
            HDAE5000_Lbn_StepDigit(HDAE5000_RAM_LbnDir, HDAE5000_RAM_LbnSong, HDAE5000_RAM_LbnDigitPos,
                                   (arg & 0x80) == 0 ? 1 : 0xffff);
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
