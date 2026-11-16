/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void PartCtrl_AdvanceReadPos(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned int __near SQSTEP_SCAN_OFFSET;
extern unsigned int __near SQSTEP_SCAN_BLOCK;

int SeqStep_SkipThreeEvents(void)
{
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	PartCtrl_AdvanceReadPos();
	if (SEQ_ERROR_CODE != 0) goto err;
	if (SeqPart_ReadByte_Secondary() == 0) goto ok;
err:
	return -1;
ok:
	return 0;
}

int SeqStep_WalkReadNext(void)
{
	unsigned int o, b;

	o = SQSTEP_SCAN_OFFSET;
	if (o == 5) {
		b = PartCtrl_ReadWord_Off1(SQSTEP_SCAN_BLOCK);
		if (b == 0) return -1;
		SQSTEP_SCAN_BLOCK = b;
		SQSTEP_SCAN_OFFSET = 255;
	} else {
		SQSTEP_SCAN_OFFSET = o + 1;
	}
	return 0;
}

/* cc900-module: SeqStep_MeasureRead SeqStep_WalkWithCallback */
extern unsigned char __near ram_2634;
extern int __near ram_287f;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_273c;
extern unsigned int __near ram_273e;
extern void SeqVoice_SeekToBar(int, int);
extern void SeqStep_MeasureRead(void);
extern void SeqStep_VelNoteBwd(int v);

void SeqStep_VelNoteBwd(int v)
{
    unsigned char m = ram_2634;
    ram_287f = v + 1;
    SeqVoice_SeekToBar(m, 0);
    if (SEQ_ERROR_CODE != 0) return;
    ram_273c = SEQ_DATA_BLOCK;
    ram_273e = SEQ_DATA_OFFSET;
    SeqStep_MeasureRead();
}

/* cc900-module: SeqStep_FindAndCompact */
extern unsigned int __near ram_2648;
extern unsigned int __near ram_264a;
extern unsigned char __near ram_264e;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqStep_AdvanceHelper1(void);
extern unsigned char __near ram_f247;
extern unsigned int __near ram_f248;
extern unsigned int __near ram_f1ce;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern void SeqData_CopyBlockToBuffer(int);
extern void VoicePreset_LoadAndInitPan(int);
extern void SeqStep_FindAndCompact(void);
extern void SeqStep_ByteBlockEA5F(void);
extern unsigned int __near ram_2644;
extern unsigned int __near ram_2646;
extern unsigned char __near ram_264c;
extern void SeqStep_SkipToHighBit(void);
extern int __near SEQ_OP_FROM;
extern unsigned int __near ram_28bf;
extern unsigned int __near ram_28c1;
extern int SeqStep_WalkWithCallback(void);
extern void SeqStep_VelNoteFwd(void);

void SeqStep_AdvanceHelper1(void)
{
    SEQ_DATA_OFFSET = ram_2648;
    SEQ_DATA_BLOCK = ram_264a;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    switch (SeqData_ReadNextByte()) {
    case 0x81:
    case 0x82:
        return;
    default:
        ram_2648 = SEQ_DATA_OFFSET;
        ram_264a = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264e = SeqData_ReadNextByte();
    }
}
void SeqStep_ByteBlockEA5F(void)
{
    unsigned int a, b, c;
    ram_f247 = SEQ_CURRENT_SONG;
    ram_f248 = SEQ_TRACK_MASK_COPY;
    SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
    SeqStep_FindAndCompact();
    a = ram_f1ce;
    b = SEQ_FREE_BLOCKS;
    c = SEQ_FREE_LIST_HEAD;
    VoicePreset_LoadAndInitPan(SEQ_CURRENT_SONG);
    ram_f1ce = a;
    SEQ_FREE_BLOCKS = b;
    SEQ_FREE_LIST_HEAD = c;
}
void SeqStep_SkipToHighBit(void)
{
    SEQ_DATA_OFFSET = ram_2644;
    SEQ_DATA_BLOCK = ram_2646;
    SeqData_AdvancePosition();
    if (SEQ_ERROR_CODE != 0) return;
    for (;;) {
        if (SeqData_ReadNextByte() & 0x80) break;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
    }
    switch (SeqData_ReadNextByte()) {
    case 0x81:
    case 0x82:
        return;
    default:
        ram_2644 = SEQ_DATA_OFFSET;
        ram_2646 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_264c = SeqData_ReadNextByte();
    }
}
void SeqStep_VelNoteFwd(void)
{
    unsigned char m;
    int v = SEQ_OP_FROM;
    int t, a;
    if (v == 1) return;
    m = ram_2634;
    t = v;
    ram_287f = t;
    a = m;
    SeqVoice_SeekToBar(a, 0);
    if (SEQ_ERROR_CODE != 0) return;
    if (SeqStep_WalkWithCallback() == 0) {
        SEQ_DATA_BLOCK = ram_28bf;
        SEQ_DATA_OFFSET = ram_28c1;
        SeqData_AdvancePosition();
    }
    ram_273e = SEQ_DATA_OFFSET;
    ram_273c = SEQ_DATA_BLOCK;
    SeqStep_MeasureRead();
}
