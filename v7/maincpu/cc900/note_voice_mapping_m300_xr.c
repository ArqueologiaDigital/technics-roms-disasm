/* Functions of audio/note_voice_mapping.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Harmony_FindReferenceNote UIParam_ScanAndCollect Voice_ResetSearchState */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern unsigned char VoiceMap_AllocateSlot(void);

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
