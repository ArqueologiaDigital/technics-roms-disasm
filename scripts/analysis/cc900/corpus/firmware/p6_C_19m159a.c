/* Phase 6, lane_p6 helper C, round 19, module 159 (modules_v10.tsv) of v10 storage/flash_floppy_handlers.s, form a:
   DualVoice_LoadAndScan.  Run 123 (round 18 form b, -Xr, +13) showed the frame and the parameter spills right and
   five differences, each addressed here:
   - stack slots: V4.23 gives the first-declared local the lowest slot; the ROM has the result at +4, the column's
     event at +6, the group at +8, the hit flag at +10, so they are declared in that order;
   - the section index: V4.23 multiplied the byte counter in 8 bits (mul A,3); the ROM widens it and multiplies
     signed (muls WA,3), adds the widened column, and reuses the row offset for the second byte: a table of
     three-byte rows indexed [i][column];
   - the loops: the ROM has no entry test (do-while from 0);
   - the result: the ROM places the epilogue right after the hit path (as SeqStep_EventAdvance, matched in run 123
     with the exit written inside the branch); here the result store and the return are inside the hit branch and
     the other exits jump there;
   - the slot-table test reads 0x73a through a pointer (the ROM: lda XWA, then (XWA) and (XWA+2)), and the match
     flag is read widened (the ROM: load, extz WA, bit 0 of WA).
   Form b (p6_C_19m159b.c): the flag read through an unsigned int cast. */
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
    unsigned int *p;
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
        if ((int)ram_35b0 & 1) {
            found = 1;
setret:
            ret = 1;
done:
            return ret;
        }
    } while (++i < 10);
    if (found != 0) goto setret;
    Flash_StoreBaseAndInitAccPatch();
    NoteEventBuffer_Store(v);
    p = ram_73a;
    if (p[0] == 0xffff && p[1] == 0xffff) goto done;
    Flash_WriteBackSlotTable();
    goto done;
}
