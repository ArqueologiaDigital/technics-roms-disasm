/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_7b.c (2026-11-16-45-p6-r9)
   sha256 097b93aed5fed7ce6eda526577e71a202b77bb96f3419f35ae2221cf3a33ea28 (tar-sha256); compiled at -O3 -Xr
   cc900-name: AccSection_SwitchNowUnlessDefer=AccSection_SwitchNowUnlessDeferred */
extern unsigned char __near ram_330c;
extern unsigned char __near ACC_PENDING_ENDING;
extern unsigned char __near ACC_DEFER_ENDING_LANES;
extern unsigned char __near ACC_PENDING_INTRO;
extern unsigned char __near ACC_PENDING_FILLIN;
extern unsigned char __near ACC_DEFER_SECTION_LANES;
extern void AccSection_SwitchNow(void);
void AccSection_SwitchNowUnlessDefer(void)
{
    if ((ram_330c & 1) || (ACC_PENDING_ENDING & 3)) {
        if (!(ACC_DEFER_ENDING_LANES & 0x3f)) goto sw;
    }
    if (!(ACC_PENDING_INTRO & 0xd) && !(ACC_PENDING_FILLIN & 3)) return;
    if (ACC_DEFER_SECTION_LANES & 0x3f) return;
sw:
    AccSection_SwitchNow();
}
