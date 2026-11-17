/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15a.c (2026-11-16-100-p6-r19)
   sha256 7caacf92b81c580e558ace02d13d4a4484a651c893c11e49cb579bb494e4fe60 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_35b0;
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
    ram_35b0 &= ~1;
    DualVoice_ParamLoadDone();
    f = ram_35b0;
    if (f & 1) {
        STYLE_SRC_IMAGE_PTR = STYLE_DST_IMAGE_PTR;
        STYLE_COPY_SRC_SECTION = STYLE_COPY_DST_SECTION;
        AccPatch_InitFromSlotIndex();
        STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        r = -107;
    }
    return r;
}
