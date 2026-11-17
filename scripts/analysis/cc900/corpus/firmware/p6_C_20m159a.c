/* Phase 6, lane_p6 helper C, round 20, module 159 (modules_v10.tsv) of v10 storage/flash_floppy_handlers.s, form a:
   DualVoice_LoadAndScan.  Run 128: at -O3 -Xr round 19 form b gives the ROM's loops, flag test and epilogue
   placement, but V4.23 dropped the hit flag (its only set was followed by the return, so it is never seen set),
   and the frame shrank by two bytes.  The ROM keeps it: it sets the flag, then takes the hit path, and tests the
   flag after the loop.  Here the hit sets the flag and leaves the loop; the result block (ret = 1, return) stays
   inside the hit branch after the break, reached from the test after the loop, so the flag stays live.  The
   slot-table test reads the array directly (round 18 at -O3 gave lda XWA with (XWA) and (XWA+2), as the ROM;
   the pointer local added a copy to XBC).  Form b (p6_C_20m159b.c): round 18's plain shape (result after the
   loop) with round 19's declarations, rows, loops and flag read. */
/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_InitExtMemAddrs Flash_StoreBaseAndInitAccPatch Flash_WriteBackSlotTable NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store */

extern long __near RHYTHM_PATTERN_BUF_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_DST_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern unsigned char __near ram_35b0;
extern unsigned int __near ram_73a[];
extern unsigned char MSP_Default_ChannelMap[][3];
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
    unsigned char ret, v, idx, found;
    unsigned char i;
    ret = 0;
    found = 0;
    Flash_InitExtMemAddrs();
    RHYTHM_PATTERN_BUF_PTR = de;
    if (a >= 10) goto done;
    DualVoice_ScanAllColumns(a);
    DualVoice_ScanAllColumnsAlt(c);
    v = NoteEvent_Store(c);
    NoteEventBuffer_CopyToSlot(v);
    AccPatch_CountSlotsAlt();
    idx = MSP_Default_GroupIndexPad[c];
    STYLE_SRC_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
    i = 0;
    do {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][idx];
        AccPatch_InitFromSlotIndex();
    } while (++i < 10);
    STYLE_SRC_IMAGE_PTR = RHYTHM_PATTERN_BUF_PTR;
    STYLE_DST_IMAGE_PTR = STYLE_WORK_IMAGE_PTR;
    ram_35b0 &= ~1;
    i = 0;
    do {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][a];
        STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i][idx];
        DualVoice_ParamLoadDone();
        if ((unsigned int)ram_35b0 & 1) {
            found = 1;
            break;
setret:
            ret = 1;
done:
            return ret;
        }
    } while (++i < 10);
    if (found != 0) goto setret;
    Flash_StoreBaseAndInitAccPatch();
    NoteEventBuffer_Store(v);
    if (ram_73a[0] == 0xffff && ram_73a[1] == 0xffff) goto done;
    Flash_WriteBackSlotTable();
    goto done;
}
