/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/flash_floppy_handlers_m159.c (2026-11-16-111-p6-r22-staged)
   sha256 3ec11e9c38d5355642332d88011f91a9fa3d3fa0405227f3abb6dea8c9d73248 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_3514;
extern long __near STYLE_DST_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern void DualVoice_ParamLoadDone(void);
extern void AccPatch_InitFromSlotIndex(void);
int AccPatch_CopySection(void)
{
    int r = 0;
    unsigned int f;
    ram_3514 &= ~1;
    DualVoice_ParamLoadDone();
    f = ram_3514;
    if (f & 1) {
        STYLE_SRC_IMAGE_PTR = STYLE_DST_IMAGE_PTR;
        STYLE_COPY_SRC_SECTION = STYLE_COPY_DST_SECTION;
        AccPatch_InitFromSlotIndex();
        STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        r = -107;
    }
    return r;
}
