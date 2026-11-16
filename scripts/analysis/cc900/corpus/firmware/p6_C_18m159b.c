/* Phase 6, lane_p6 helper C, round 18, module 159 (modules_v10.tsv) of v10 storage/flash_floppy_handlers.s, form b
   of DualVoice_LoadAndScan (form a, p6_C_18m159a.c, describes it): the ROM reads the match flag by loading the
   byte, widening it and testing bit 0 of WA, and clears it with res: here bit 0 of 0x35b0 is an unsigned char
   bitfield (they fill from bit 7 down, so it is the second field).  The section indexes are written
   column + i * 3, and the match path sets both flags and returns from inside the loop. */
/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_InitExtMemAddrs Flash_StoreBaseAndInitAccPatch Flash_WriteBackSlotTable NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store */

struct flag35b0 { unsigned char rest : 7; unsigned char hit : 1; };

extern long __near RHYTHM_PATTERN_BUF_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_DST_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern struct flag35b0 __near ram_35b0;
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
    if (a >= 10) return ret;
    DualVoice_ScanAllColumns(a);
    DualVoice_ScanAllColumnsAlt(c);
    v = NoteEvent_Store(c);
    NoteEventBuffer_CopyToSlot(v);
    AccPatch_CountSlotsAlt();
    idx = MSP_Default_GroupIndexPad[c];
    STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
    for (i = 0; i < 10; i++) {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[idx + i * 3];
        AccPatch_InitFromSlotIndex();
    }
    STYLE_SRC_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
    STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
    ram_35b0.hit = 0;
    for (i = 0; i < 10; i++) {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[a + i * 3];
        STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[idx + i * 3];
        DualVoice_ParamLoadDone();
        if (ram_35b0.hit) {
            found = 1;
            ret = 1;
            return ret;
        }
    }
    if (found != 0) {
        ret = 1;
        return ret;
    }
    Flash_StoreBaseAndInitAccPatch();
    NoteEventBuffer_Store(v);
    if (ram_73a[0] == 0xffff && ram_73a[1] == 0xffff) return ret;
    Flash_WriteBackSlotTable();
    return ret;
}
