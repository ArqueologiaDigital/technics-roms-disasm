/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_mode_handlers_m0.c (2026-11-16-68-p6-r12)
   sha256 1b1bea89001823cf154e0adff813e3b388cc1817afdc5a64111ea814e4639a2d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_SHOW                      0x1c00001L
#define NAKA_VIEW_TEST51              0xf80006L
#define NAKA_VIEW_TEST52              0xf80008L
#define NAKA_VIEW_TEST53              0xf8000aL
#define NAKA_VIEW_TEST54              0xf8000cL
#define NAKA_VIEW_TEST55              0xf8000eL
#define NAKA_VIEW_TEST56              0xf80010L
extern long ApPostEvent(long, long, long);
extern unsigned char __near DIAG_ANIM_STEP;
extern int CtrlPanel_GetSelectionState(void);
void EffectMode_HandleTimerEvents(void)
{
    if (CtrlPanel_GetSelectionState()) return;
    switch (DIAG_ANIM_STEP) {
    case 0:
        ApPostEvent(NAKA_VIEW_TEST54, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 30:
        ApPostEvent(NAKA_VIEW_TEST55, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 60:
        ApPostEvent(NAKA_VIEW_TEST56, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 90:
        ApPostEvent(NAKA_VIEW_TEST51, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 120:
        ApPostEvent(NAKA_VIEW_TEST52, EVT_SHOW, 0);
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    case 150:
        ApPostEvent(NAKA_VIEW_TEST53, EVT_SHOW, 0);
        DIAG_ANIM_STEP = 220;
        break;
    default:
        ++DIAG_ANIM_STEP;
        ++DIAG_ANIM_STEP;
        break;
    }
}
