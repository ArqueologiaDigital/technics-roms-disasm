/* Functions of storage/flash_floppy_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/



/* cc900-name: Flash_StoreBaseAccPatch_Helper=Flash_StoreBaseAndInitAccPatch_Helper (the label shares its first 31
   characters with the other Flash_StoreBaseAndInitAccPatch_* labels) */
unsigned char Flash_StoreBaseAccPatch_Helper(unsigned char a)
{
	unsigned char r;

	if (a < 10) r = a + 48;
	else if (a < 20) r = a + 38;
	else if (a < 30) r = a + 28;
	else if (a < 40) r = a + 18;
	else r = a + 8;
	return r;
}

unsigned int Pack12BitValueWithBank(unsigned int v, unsigned char b)
{
	unsigned int r = v;

	if (r == 0xffff) return r;
	r &= 0xfff;
	r |= (unsigned int)b << 12;
	return r;
}

extern unsigned char __near ram_35b0;
extern long __near STYLE_DST_IMAGE_PTR;
extern long __near STYLE_SRC_IMAGE_PTR;
extern long __near STYLE_WORK_IMAGE_PTR;
extern unsigned char __near STYLE_COPY_SRC_SECTION;
extern unsigned char __near STYLE_COPY_DST_SECTION;
extern void DualVoice_ParamLoadDone(void);
extern void AccPatch_InitFromSlotIndex(void);
extern int AccPatch_CopySection(void);

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

/* cc900-module: DualVoice_ScanAllColumns DualVoice_ScanAllColumnsAlt Flash_InitExtMemAddrs Flash_StoreBaseAndInitAccPatch Flash_WriteBackSlotTable NoteEventBuffer_CopyToSlot NoteEventBuffer_Store NoteEvent_Store */
extern long __near RHYTHM_PATTERN_BUF_PTR;
extern unsigned int __near ram_73a[];
extern unsigned char MSP_Default_ChannelMap[][3];
extern unsigned char MSP_Default_GroupIndexPad[];
extern void Flash_InitExtMemAddrs(void);
extern void DualVoice_ScanAllColumns(int);
extern void DualVoice_ScanAllColumnsAlt(int);
extern unsigned char NoteEvent_Store(int);
extern void NoteEventBuffer_CopyToSlot(int);
extern void AccPatch_CountSlotsAlt(void);
extern void Flash_StoreBaseAndInitAccPatch(void);
extern void NoteEventBuffer_Store(int);
extern void Flash_WriteBackSlotTable(void);
extern unsigned char DualVoice_LoadAndScan(unsigned char a, unsigned char c, long de);

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

/* cc900-module: Flash_InitBytecodeBlock_Helper8 Flash_InitBytecodeBlock_Helper9 */
extern void Flash_InitBytecodeBlock_Helper8(unsigned int, unsigned int, unsigned int);
extern void Flash_InitBytecodeBlock_Helper9(unsigned int, unsigned int, unsigned int);
extern unsigned char __near ram_c68;
extern unsigned char __near ram_c6a;
extern unsigned char __near ram_c6c;
extern unsigned char CstmCpTtl_ResolvePendingCopy(unsigned char mode);

unsigned char CstmCpTtl_ResolvePendingCopy(unsigned char mode)
{
	unsigned char a;
	unsigned char b;
	unsigned char c;

	Flash_InitExtMemAddrs();
	a = ram_c68;
	b = ram_c6a;
	c = ram_c6c;
	switch (mode) {
	case 0:
		if (a < 10)
			Flash_InitBytecodeBlock_Helper8(a, b, c);
		else
			Flash_InitBytecodeBlock_Helper9(a, b, c);
		break;
	case 2:
		break;
	}
	return 0;
}
