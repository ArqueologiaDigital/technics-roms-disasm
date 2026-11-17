/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/flash_floppy_handlers_m159.c (2026-11-16-111-p6-r22-staged)
   sha256 857b32888ea6462e33d5d1dfec6e3c32325cbc20cf3bc7b531954582dd9a47da (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
