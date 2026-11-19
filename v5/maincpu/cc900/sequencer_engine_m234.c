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
extern unsigned int __near ram_2859;
extern unsigned char __near ram_2889;
extern void SeqAcc_InitPlaybackState(void);
extern void CtrlPanel_SetIndicatorBit(int);

void SeqAcc_RestorePlaybackState(void)
{
  unsigned int m = ram_2859;
  SEQ_TRACK_MASK = m;
  Audio_CheckSubsystemReady();
  if (m != 0) {
    SEQ_RTMCFG &= ~0x08;
    SeqAcc_InitPlaybackState();
    Audio_CheckSubsystemReady();
    ram_2889 |= 0x01;
  } else ram_2889 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

extern unsigned char ram_b0000[];
extern unsigned int PartCtrl_ReadWord(unsigned int n);

unsigned int PartCtrl_ReadWord(unsigned int n)
{
  return *(unsigned int *)((unsigned long)ram_b0000 + (((unsigned long)(n - 1) << 8) + 3));
}

extern unsigned char __near ram_1d7e;
extern unsigned char __near ram_1d80;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);
extern void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n);

void SeqBuf_WriteMidiEvent(unsigned char *ev, unsigned char n)
{
	if ((*ev & 0xf0) == 0x90) {
		if (ram_1d80 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d7e = 1;
	} else {
		if (ram_1d7e != 0)
			SeqBuf_FlushAndReinit_NoteEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		SeqBuf_WriteBytes(n, ev);
		ram_1d80 = 1;
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
extern unsigned char __near ram_2871;
extern unsigned char __near ram_2872;
extern unsigned int __near ram_ce3;
extern int SeqVoice_CountEventsInBar(unsigned char ch);
extern void SeqBuf_WriteMidiEventDirect(unsigned char *ev, unsigned char n);
extern unsigned char __near ram_26c8;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near PART_SELECT;
extern unsigned char PartDetect_LookupAndApply_Table[];
extern void PartSelect_UpdateDisplayState(void);
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void Part_DetectSingleVoiceType(void);
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_2502;
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
	ram_2871 = 0;
	Part_ValidateVoiceChannel(ch);
	if (SEQ_ERROR_CODE != 0)
		return -1;
	SeqVoice_ValidateAndProcessState();
	r = 1;
	n = 0;
	k = 0;
	while (n != ram_ce3) {
		if (ram_2872 == k) {
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
		if (ram_1d80 != 0)
			SeqBuf_FlushAndReinit_VoiceCCEvents();
		if (SeqBuf_GetWritePos() < 15)
			SeqBuf_FlushAndReinit_NoteEvents();
		SeqBuf_WriteBytes(n, ev);
		SeqBuf_FlushAndReinit_NoteEvents();
	} else {
		if (ram_1d7e != 0)
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

	ram_26c8 &= ~0x01;
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
	ram_26c8 |= 0x01;
	PART_SELECT = f;
	AddswbWr(0x90, 0x10, f, 0xff);
}
void SeqVoice_ActivateWithBarSync(unsigned char t)
{
	unsigned int w;

	if (SEQ_TRACK_MASK == 0) {
		if (!(SEQ_CYCLE_FLAGS & 0x01) || SEQ_START_MEASURE <= (w = ram_2502))
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
