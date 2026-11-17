/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/note_voice_mapping_m300_xr.c (2026-11-16-103-p6-r20-staged)
   sha256 3e1f096d9a8b649afcd0c2b16730996b2c6ba6bf5434edf12f9b06c74ae8dda8 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int __near ram_cdca;
extern unsigned int __near ram_cdcc;
extern unsigned int __near ram_cd88;
extern unsigned int __near HARMONY_NOTE_LIST;
extern unsigned char __near HARMONY_REF_NOTE;
extern unsigned char __near HARMONY_PREV_REF_NOTE;
extern unsigned char __near CHORD_TYPE;
extern unsigned char __near CHORD_ROOT;
extern unsigned char __near ram_ce12;
extern unsigned char __near ram_ce14;
extern unsigned char __near ram_ce16;
extern unsigned char __near ram_e8f6;
extern unsigned char Harmony_FindReferenceNote(unsigned int *list);
extern void UIParam_ScanAndCollect(void);
extern void Voice_ResetSearchState(void);
unsigned char VoiceMap_AllocateSlot(void)
{
    unsigned char r;
    r = 0xff;
    if (ram_cdca == 0) {
        if (Harmony_FindReferenceNote(&HARMONY_NOTE_LIST) != 0xff) {
            UIParam_ScanAndCollect();
            ram_ce12 = CHORD_TYPE;
            ram_ce14 = CHORD_ROOT;
            r = ram_cd88;
        } else
            r = 0xff;
    } else if (HARMONY_NOTE_LIST == 0) {
        Voice_ResetSearchState();
        ram_ce12 = 255;
        ram_ce14 = 255;
        r = ram_cd88;
    } else {
        if (Harmony_FindReferenceNote(&HARMONY_NOTE_LIST) != 0xff) {
            ram_e8f6 = 10;
            if (HARMONY_PREV_REF_NOTE != HARMONY_REF_NOTE || ram_cd88 != ram_cdcc)
                ram_ce16 = 1;
        }
        r = 0xff;
    }
    return r;
}
