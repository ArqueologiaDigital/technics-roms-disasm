/* Phase 6, lane_p6 helper C, round 18, module 159 (modules_v10.tsv) of v10 storage/flash_floppy_handlers.s, form a:
   DualVoice_LoadAndScan (new, memory-to-memory pool).  For a voice section a (< 10) and a column c: scans both
   columns, stores c's note event, then copies the ten sections of the group c selects (MSP_Default_GroupIndexPad)
   from the work image, and compares section a with that group's sections through DualVoice_ParamLoadDone; on the
   first hit returns 1, else stores the event buffer and writes back the slot table unless its first two words
   are both 0xffff.  The ROM keeps a and c on the stack, the loop counter in QIZH, and copies the table bytes into
   the __near section cells memory to memory; the section index is i * 3 + column, multiplied signed (muls).
   Form b (p6_C_18m159b.c): the flag bit 0 of 0x35b0 as a bitfield, and the index written column + i * 3. */
/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_InitExtMemAddrs Flash_StoreBaseAndInitAccPatch Flash_WriteBackSlotTable NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store */

extern long __near RHYTHM_PATTERN_BUF_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_DST_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern unsigned char __near ram_35b0;
extern unsigned int __near ram_73a[];
extern unsigned char MSP_Default_ChannelMap[];
extern unsigned char MSP_Default_GroupIndexPad[];

extern void Flash_InitExtMemAddrs(void);
extern void DualVoice_ScanAllColumns(int);
extern void DualVoice_ScanAllColumnsAlt(int);
extern unsigned char NoteEvent_Store(int);
extern void NoteEventBuffer_CopyToSlot(int);
extern void AccPatch_CountSlotsAlt(void);
extern void AccPatch_InitFromSlotIndex(void);
extern void DualVoice_ParamLoadDone(void);
extern void Flash_StoreBaseAndInitAccPatch(void);
extern void NoteEventBuffer_Store(int);
extern void Flash_WriteBackSlotTable(void);

unsigned char DualVoice_LoadAndScan(unsigned char a, unsigned char c, long de)
{
    unsigned char found, idx, v, ret;
    unsigned char i;
    ret = 0;
    found = 0;
    Flash_InitExtMemAddrs();
    RHYTHM_PATTERN_BUF_PTR = de;
    if (a < 10) {
        DualVoice_ScanAllColumns(a);
        DualVoice_ScanAllColumnsAlt(c);
        v = NoteEvent_Store(c);
        NoteEventBuffer_CopyToSlot(v);
        AccPatch_CountSlotsAlt();
        idx = MSP_Default_GroupIndexPad[c];
        STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        for (i = 0; i < 10; i++) {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i * 3 + idx];
            AccPatch_InitFromSlotIndex();
        }
        STYLE_SRC_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
        STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
        ram_35b0 &= ~1;
        for (i = 0; i < 10; i++) {
            STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i * 3 + a];
            STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i * 3 + idx];
            DualVoice_ParamLoadDone();
            if (ram_35b0 & 1) {
                found = 1;
                break;
            }
        }
        if (found != 0) {
            ret = 1;
        } else {
            Flash_StoreBaseAndInitAccPatch();
            NoteEventBuffer_Store(v);
            if (ram_73a[0] != 0xffff || ram_73a[1] != 0xffff) Flash_WriteBackSlotTable();
        }
    }
    return ret;
}
