/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_7a.c (2026-11-16-45-p6-r9)
   sha256 f75669701267b77dffaa5335c29cabf57bf854482b882bba194a9f14b1c82c30 (tar-sha256); compiled at -O3 -Xr
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
    if ((((ram_330c & 1) || (ACC_PENDING_ENDING & 3)) && !(ACC_DEFER_ENDING_LANES & 0x3f))
        || (((ACC_PENDING_INTRO & 0xd) || (ACC_PENDING_FILLIN & 3)) && !(ACC_DEFER_SECTION_LANES & 0x3f)))
        AccSection_SwitchNow();
}
