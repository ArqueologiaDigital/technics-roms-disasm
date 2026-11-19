/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord */   /* staged module names, repair_module_lines.py */

extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern unsigned int __near ram_2875;
extern unsigned char __near ram_28a5;
extern void SeqAcc_InitPlaybackState(void);
extern void CtrlPanel_SetIndicatorBit(int);

void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2875;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_28a5 |= 0x01;
  } else ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);

unsigned int PartCtrl_ReadWord(unsigned int n)
{
  return *(unsigned int *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 3));
}

extern unsigned char __near ram_1d84;
extern unsigned char __near ram_1d86;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
extern void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n);

void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d86 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d84 = 1;
	} else {
		if (ram_1d84 != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d86 = 1;
	}
}

/* cc900-module: Chan_SetActiveBit PartCtrl_TestBit7 Part_ReadVoiceByte Part_ValidateVoiceChannel SeqBuf_FlushAndReinit_NoteEvents SeqBuf_FlushAndReinit_VoiceCCEvents SeqData_AdvancePosition SeqData_ReadNextByte SeqTrack_ProcessControlBytes SeqVoice_SetDefaultParams SeqVoice_UpdateSubBlockAssign SeqVoice_ValidateAndProcessState */
extern void SeqVoice_SetDefaultParams(void);
extern void Part_ValidateVoiceChannel(unsigned int);
extern void SeqVoice_ValidateAndProcessState(void);
extern void SeqTrack_ProcessControlBytes(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_AdvancePosition(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_288d;
extern unsigned char __near ram_288e;
extern unsigned int __near ram_ce3;
extern int SeqVoice_CountEventsInBar(unsigned char ch);
extern void SeqBuf_WriteMidiEventDirect(unsigned char *ev, unsigned char n);
extern unsigned char __near ram_26e2;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near PART_SELECT;
extern unsigned char PartDetect_LookupAndApply_Table[];
extern void PartSelect_UpdateDisplayState(void);
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void Part_DetectSingleVoiceType(void);
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_251c;
extern void NoteEditSy_SendModeScrollReset(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqVoice_UpdateSubBlockAssign(unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void SeqVoice_ActivateWithBarSync(unsigned char t);

int SeqVoice_CountEventsInBar(unsigned char ch)
{
	int k;
	int r;
	int n;
	unsigned char b;

	SeqVoice_SetDefaultParams();
	SEQ_ERROR_CODE = 0;
	ram_288d = 0;
	Part_ValidateVoiceChannel(ch);
	if (SEQ_ERROR_CODE != 0)
		return -1;
	SeqVoice_ValidateAndProcessState();
	r = 1;
	n = 0;
	k = 0;
	while (n != ram_ce3) {
		if (ram_288e == k) {
			r++;
			SeqTrack_ProcessControlBytes();
			k = 0;
		}
		b = SeqData_ReadNextByte();
		if (b == 0x82 || b == 0x84) {
			SEQ_ERROR_CODE = 8;
			break;
		}
		if (b == 0x81) {
			k++;
			n++;
		}
		SeqData_AdvancePosition();
		if (SEQ_ERROR_CODE != 0)
			break;
	}
	return r;
}
void SeqBuf_WriteMidiEventDirect(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d86 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		SeqBuf_FlushAndReinit_NoteEvents();
	} else {
		if (ram_1d84 != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		SeqBuf_FlushAndReinit_VoiceCCEvents();
	}
}
void Part_DetectSingleVoiceType(void)
{
	unsigned char i;
	unsigned char n;
	unsigned char f;
	unsigned char v;

	ram_26e2 &= ~0x01;
	n = 0;
	i = 1;
	do {
		if ((1 << (i - 1)) & SEQ_REC_TRACKS) {
			n++;
			f = i;
		}
	} while (n <= 1 && ++i <= 16);
	if (n != 1) {
		PartSelect_UpdateDisplayState();
		return;
	}
	v = Part_ReadVoiceByte(0, f);
	if (v == 15)
		return;
	if (v > 0x13)
		v = 0;
	f = PartDetect_LookupAndApply_Table[v];
	ram_26e2 |= 0x01;
	PART_SELECT = f;
	AddswbWr(0x90, 0x10, f, 0xff);
}
void SeqVoice_ActivateWithBarSync(unsigned char t)
{
	unsigned int w;

	if (SEQ_TRACK_MASK == 0) {
		if (!(SEQ_CYCLE_FLAGS & 0x01) || SEQ_START_MEASURE <= (w = ram_251c))
			SEQ_START_MEASURE = 1;
		else
			SEQ_START_MEASURE = w;
		NoteEditSy_SendModeScrollReset();
		if (SEQ_START_MEASURE == 1)
			SEQ_RTMCFG &= ~0x08;
		else
			SEQ_RTMCFG |= 0x08;
		AccWrap_PlayModeDispatch();
	}
	SeqVoice_UpdateSubBlockAssign(t);
	Chan_SetActiveBit(t, 1);
	Audio_CheckSubsystemReady();
}

/* cc900-module: Part_ReadByteDirect Part_ReadVoiceWord Part_SetClearVoiceBit7 Part_StealAndReallocVoices Part_WriteByte Part_WriteByte_Indexed Part_WriteVoiceWord Part_WriteWord_Indexed SeqNotePool_Init Seq_ValidatePartNumber Seq_ValidateTempoValue */
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned int, unsigned int, unsigned int);
extern void Part_StealAndReallocVoices(unsigned int);
extern void Part_SetClearVoiceBit7(unsigned char s, unsigned char p, unsigned char on);
extern void Part_ClearAndStealSingleVoice(unsigned char p);
extern void SeqNotePool_Init(unsigned int);
extern void SeqBuf_WriteNoteOffEntry(unsigned char ch);
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned int __near SEQ_OP_FROM;
extern unsigned int __near SEQ_OP_MEASURES;
extern unsigned int __near SEQ_OP_DEST_MEASURE;
extern int Seq_ValidatePartNumber(unsigned int);
extern int Seq_ValidateTempoValue(unsigned int);
extern int Seq_ValidatePartAndTempo(void);

void Part_ClearAndStealSingleVoice(unsigned char p)
{
	unsigned int v;

	Part_SetClearVoiceBit7(0, p, 0);
	v = Part_ReadVoiceWord(0, p);
	Part_WriteVoiceWord(0, p, 0xffff);
	Part_WriteWord_Indexed(0, p, 0xffff);
	Part_WriteByte_Indexed(0, p, 5);
	Part_StealAndReallocVoices(v);
}
void SeqBuf_WriteNoteOffEntry(unsigned char ch)
{
	unsigned char b[8];

	if (ram_1d86 != 0)
		SeqBuf_FlushAndReinit_VoiceCCEvents();
	b[0] = 0x90;
	b[1] = 0x7f;
	b[2] = 0;
	b[3] = 0;
	if (ch == 0x32)
		b[4] = 0x7f;
	else
		b[4] = ch - 1;
	SeqBuf_WriteBytes(5, b);
	SeqBuf_FlushAndReinit_NoteEvents();
	if (ch == 0x32)
		SeqNotePool_Init(0x32);
}
int Seq_ValidatePartAndTempo(void)
{
	if (SEQ_TRACK != 0x7f) {
		if (Seq_ValidatePartNumber(SEQ_TRACK) != 0)
			return -1;
		if (Seq_ValidatePartNumber(SEQ_OP_DEST_TRACK) != 0)
			return -1;
	}
	if (Seq_ValidateTempoValue(SEQ_OP_FROM) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_MEASURES) != 0)
		return -1;
	if (Seq_ValidateTempoValue(SEQ_OP_DEST_MEASURE) != 0)
		return -1;
	return 0;
}
