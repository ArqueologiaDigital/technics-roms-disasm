/* cc900-module: Harmony_FindReferenceNote UIParam_ScanAndCollect Voice_ResetSearchState */
/* Phase 6, lane_p6 helper A, round 16, form b: module 300 (audio/note_voice_mapping.s), VoiceMap_AllocateSlot with
   one result variable and a single return (the ROM shares one `ret`, reached by jumps). */
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
        if (Harmony_FindReferenceNote(&HARMONY_NOTE_LIST) != 0xff) {
            UIParam_ScanAndCollect();
            ram_ceae = CHORD_TYPE;
            ram_ceb0 = CHORD_ROOT;
            r = ram_ce24;
        } else
            r = 0xff;
    } else if (HARMONY_NOTE_LIST == 0) {
        Voice_ResetSearchState();
        ram_ceae = 255;
        ram_ceb0 = 255;
        r = ram_ce24;
    } else {
        if (Harmony_FindReferenceNote(&HARMONY_NOTE_LIST) != 0xff) {
            ram_e9bc = 10;
            if (HARMONY_PREV_REF_NOTE != HARMONY_REF_NOTE || ram_ce24 != ram_ce68)
                ram_ceb2 = 1;
        }
        r = 0xff;
    }
    return r;
}
