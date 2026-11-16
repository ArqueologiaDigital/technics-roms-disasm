/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_5a.c (2026-11-16-40-p6-r8)
   sha256 58315a41666f04ee926133487ef86173e174b0df3b0582b8acb925367c6d231d (tar-sha256); compiled at -Xr */
extern unsigned char __near STYLE_SECTION_BEATS;
extern void RhythmConfig_ReturnStub(void);
void AccPatch_CheckConfigType(void)
{
    if (STYLE_SECTION_BEATS == 6 || STYLE_SECTION_BEATS == 8 || STYLE_SECTION_BEATS == 4 || STYLE_SECTION_BEATS == 3)
        RhythmConfig_ReturnStub();
}
