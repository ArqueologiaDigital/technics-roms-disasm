/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/flash_floppy_handlers_m159.c (2026-11-17-6-p6-r30-staged)
   sha256 e9eb8f4d137cae0ef03db39abe1494929bf8df7f724b9cde200f4051e6152f61 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern long __near RHYTHM_PATTERN_BUF_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_DST_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern unsigned char __near ram_34f8;
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
    ram_34f8 &= ~1;
    i = 0;
    do {
        STYLE_COPY_SRC_SECTION = MSP_Default_ChannelMap[i][a];
        STYLE_COPY_DST_SECTION = MSP_Default_ChannelMap[i][idx];
        DualVoice_ParamLoadDone();
        if ((unsigned int)ram_34f8 & 1) {
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
