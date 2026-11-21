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

/* cc900-module: SeqStep_FindAndCompact SeqStep_MeasureRead SeqStep_WalkWithCallback */
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near ram_262e;
extern unsigned int __near ram_2630;
extern unsigned char __near ram_2634;
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
extern unsigned int __near ram_262a;
extern unsigned int __near ram_262c;
extern unsigned char __near ram_2632;
extern void SeqStep_SkipToHighBit(void);

void SeqStep_AdvanceHelper1(void)
{
    SEQ_DATA_OFFSET = ram_262e;
    SEQ_DATA_BLOCK = ram_2630;
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
        ram_262e = SEQ_DATA_OFFSET;
        ram_2630 = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_2634 = SeqData_ReadNextByte();
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
    SEQ_DATA_OFFSET = ram_262a;
    SEQ_DATA_BLOCK = ram_262c;
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
        ram_262a = SEQ_DATA_OFFSET;
        ram_262c = SEQ_DATA_BLOCK;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) return;
        ram_2632 = SeqData_ReadNextByte();
    }
}

extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int __near ram_2722;
extern unsigned int __near ram_2724;
extern void PartCtrl_WriteByte_Indexed(int);
extern void SeqStep_EventAdvance(void);

void SeqStep_EventAdvance(void)
{
    unsigned char c, d;
    unsigned int blk, off;
    blk = SEQ_DATA_BLOCK;
    off = SEQ_DATA_OFFSET;
    if (!(SEQ_EDIT_FLAGS & 1)) return;
    SEQ_DATA_BLOCK = ram_2722;
    SEQ_DATA_OFFSET = ram_2724;
    for (;;) {
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) {
restore:
            SEQ_DATA_BLOCK = blk;
            SEQ_DATA_OFFSET = off;
            return;
        }
        if (SeqData_ReadNextByte() == 0x7f) break;
        do {
            SeqData_AdvancePosition();
            if (SEQ_ERROR_CODE != 0) goto restore;
        } while (!(SeqData_ReadNextByte() & 0x80));
        ram_2722 = SEQ_DATA_BLOCK;
        ram_2724 = SEQ_DATA_OFFSET;
    }
    SEQ_DATA_OFFSET = ram_2724;
    SEQ_DATA_BLOCK = ram_2722;
    c = SeqData_ReadNextByte();
    PartCtrl_WriteByte_Indexed(0x81);
    for (;;) {
        if (c == 0x81) goto restore;
        SeqData_AdvancePosition();
        if (SEQ_ERROR_CODE != 0) goto restore;
        d = c;
        c = SeqData_ReadNextByte();
        PartCtrl_WriteByte_Indexed(d);
        if (d & 0x80) c = 0;
    }
}

extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern void SeqPart_WriteByte_Primary(int);
extern void PartCtrl_NavigateBackward(void);
extern void PartCtrl_AdvanceToNextEntry(void);
extern void PartCtrl_NavigateBackwardAlt(void);
extern void SeqStep_DeleteShiftEvents(void);

void SeqStep_DeleteShiftEvents(void)
{
    unsigned char buf[8];
    unsigned int i, j;
    unsigned char r;
    SEQOP_SECONDARY_BLOCK = ram_2630;
    SEQOP_SECONDARY_OFFSET = ram_262e;
    i = 0;
    buf[i++] = SeqPart_ReadByte_Secondary();
    PartCtrl_AdvanceReadPos();
    if (SEQ_ERROR_CODE == 0) goto collect;
    return;
    for (;;) {
        PartCtrl_AdvanceReadPos();
        if (SEQ_ERROR_CODE != 0) return;
collect:
        r = SeqPart_ReadByte_Secondary();
        buf[i++] = r;
        if (r & 0x80) break;
    }
    i--;
    PartCtrl_NavigateBackward();
    SEQOP_PRIMARY_BLOCK = SEQOP_SECONDARY_BLOCK;
    SEQOP_PRIMARY_OFFSET = SEQOP_SECONDARY_OFFSET;
    SEQOP_SECONDARY_BLOCK = ram_2630;
    SEQOP_SECONDARY_OFFSET = ram_262e;
    PartCtrl_NavigateBackward();
    for (;;) {
        r = SeqPart_ReadByte_Secondary();
        if (SEQOP_SECONDARY_BLOCK == ram_262c && SEQOP_SECONDARY_OFFSET == ram_262a) {
            SeqPart_WriteByte_Primary((unsigned int)r);
            SEQOP_PRIMARY_BLOCK = ram_262c;
            SEQOP_PRIMARY_OFFSET = ram_262a;
            j = 0;
            if (j >= i) return;
write:
            SeqPart_WriteByte_Primary(buf[j]);
            PartCtrl_AdvanceToNextEntry();
            if (SEQ_ERROR_CODE == 0) goto next;
            return;
        }
        SeqPart_WriteByte_Primary((int)r);
        PartCtrl_NavigateBackward();
        if (SEQ_ERROR_CODE != 0) return;
        PartCtrl_NavigateBackwardAlt();
        if (SEQ_ERROR_CODE != 0) return;
    }
next:
    j++;
    if (j < i) goto write;
}

/* cc900-module: SeqStep_InsertEventInner SeqStep_ParseRhythm SeqStep_PlaybackStateMachine SeqStep_PrepareReadBack SeqStep_RebuildPartChain SeqStep_SearchForward SeqStep_SkipToMeasure SeqStep_TimerDispatchA SeqStep_TimerDispatchB */
extern unsigned int SeqStep_SearchForward(unsigned int);
extern void SeqStep_RebuildPartChain(unsigned int);
extern void SeqStep_FindAndCompactEntry(void);
extern unsigned char SeqStep_PrepareReadBack(void);
extern void SeqStep_InsertEventInner(void);
extern void SeqStep_InsertEvent(void);
extern void SeqStep_TimerDispatchA(void);
extern void SeqStep_TimerDispatchB(void);
extern void SeqStep_PlaybackStateMachine(void);
extern void SeqPlay_SyncPlaybackPosition(void);
extern void Seq_HandleModeTransition(void);
extern void SeqNotify_CheckAndClearStart(void);
extern void SeqPlay_SetupRhythmMode(void);
extern void PlaybackMode_DispatchByType(void);
extern void SeqTimer_CheckPlaybackCountdown(void);
extern void BmDrEdit_TempoAnimTimer(void);
extern void SeqStep_MainTimerTick(void);
extern int SeqStep_SkipToMeasure(unsigned int);
extern int SeqStep_SkipInvertedA(unsigned char m);
extern unsigned char __near ram_22f6;
extern void (*SeqStep_TimerDispatchC_PtrTable[])(void);
extern void SeqStep_TimerDispatchC(void);
extern int SeqStep_SkipInvertedB(unsigned char a);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern unsigned char SeqStep_WalkReadByte(void);

void SeqStep_FindAndCompactEntry(void)
{
  SeqStep_RebuildPartChain(SeqStep_SearchForward(1));
}
void SeqStep_InsertEvent(void)
{
  if (SeqStep_PrepareReadBack() != 0x81)
    SeqStep_InsertEventInner();
}
void SeqStep_MainTimerTick(void)
{
  SeqStep_TimerDispatchA();
  SeqPlay_SyncPlaybackPosition();
  SeqStep_TimerDispatchB();
  Seq_HandleModeTransition();
  SeqNotify_CheckAndClearStart();
  SeqStep_PlaybackStateMachine();
  SeqPlay_SetupRhythmMode();
  PlaybackMode_DispatchByType();
  SeqTimer_CheckPlaybackCountdown();
  BmDrEdit_TempoAnimTimer();
}
int SeqStep_SkipInvertedA(unsigned char m)
{
  if (SeqStep_SkipToMeasure(m) != 0) return -1;
  return 0;
}
void SeqStep_TimerDispatchC(void)
{
  (*SeqStep_TimerDispatchC_PtrTable[ram_22f6])();
}
int SeqStep_SkipInvertedB(unsigned char a)
{
  if (SeqStep_SkipToMeasure(a) != 0) return -1;
  return 0;
}
unsigned char SeqStep_WalkReadByte(void)
{
  return PartCtrl_ReadByte(SQSTEP_SCAN_BLOCK, (unsigned char)SQSTEP_SCAN_OFFSET);
}
