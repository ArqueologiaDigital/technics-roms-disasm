/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_16m300a.c (2026-11-16-100-p6-r19)
   sha256 9ae6194b54a63d218ec8619a5f789a75af58c4d9c5cbcfd848cc5cdff00a47a3 (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_ce66;
extern unsigned int __near ram_ce68;
extern unsigned int __near ram_ce24;
extern unsigned int __near HARMONY_NOTE_LIST;
extern unsigned char __near HARMONY_REF_NOTE;
extern unsigned char __near HARMONY_PREV_REF_NOTE;
extern unsigned char __near CHORD_TYPE;
extern unsigned char __near CHORD_ROOT;
extern unsigned char __near ram_ceae;
extern unsigned char __near ram_ceb0;
extern unsigned char __near ram_ceb2;
extern unsigned char __near ram_e9bc;
extern unsigned char Harmony_FindReferenceNote(unsigned int *list);
extern void UIParam_ScanAndCollect(void);
extern void Voice_ResetSearchState(void);
unsigned char VoiceMap_AllocateSlot(void)
{
    unsigned char r;
    r = 0xff;
    if (ram_ce66 == 0) {
        if (Harmony_FindReferenceNote(&HARMONY_NOTE_LIST) == 0xff)
            return 0xff;
        UIParam_ScanAndCollect();
        ram_ceae = CHORD_TYPE;
        ram_ceb0 = CHORD_ROOT;
        return ram_ce24;
    }
    if (HARMONY_NOTE_LIST == 0) {
        Voice_ResetSearchState();
        ram_ceae = 255;
        ram_ceb0 = 255;
        return ram_ce24;
    }
    if (Harmony_FindReferenceNote(&HARMONY_NOTE_LIST) != 0xff) {
        ram_e9bc = 10;
        if (HARMONY_PREV_REF_NOTE != HARMONY_REF_NOTE || ram_ce24 != ram_ce68)
            ram_ceb2 = 1;
    }
    return r;
}
