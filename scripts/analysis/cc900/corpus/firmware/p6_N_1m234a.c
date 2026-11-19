/* lane_p6 helper N, round 1, form a: module 234 (sequencer/sequencer_engine.s).
   SeqBuf_WriteMidiEventDirect: twin of the built SeqBuf_WriteMidiEvent (cc900/sequencer_engine_m234.c) that flushes
   the matching buffer at the end instead of setting its pending flag.
   SeqVoice_ActivateWithBarSync: with no track active, resets the start measure (1, or the saved measure while
   cycle play is on and it is below the current one) and the RTMCFG bit 3, then assigns and enables the track.
   Form a: plain C (a char parameter used across calls is homed in the frame by V4.23 -O3 itself).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Chan_SetActiveBit Part_ReadVoiceByte SeqBuf_FlushAndReinit_NoteEvents SeqBuf_FlushAndReinit_VoiceCCEvents SeqVoice_UpdateSubBlockAssign */

extern unsigned char __near ram_1d84;
extern unsigned char __near ram_1d86;
extern int SeqBuf_GetWritePos(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern void SeqBuf_FlushAndReinit_VoiceCCEvents(void);
extern void __cdecl SeqBuf_WriteBytes(unsigned int n, unsigned char *p);

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

extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_251c;
extern unsigned char __near SEQ_RTMCFG;
extern void NoteEditSy_SendModeScrollReset(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqVoice_UpdateSubBlockAssign(unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void Audio_CheckSubsystemReady(void);

void SeqVoice_ActivateWithBarSync(unsigned char t)
{
	if (SEQ_TRACK_MASK == 0) {
		if ((SEQ_CYCLE_FLAGS & 0x01) && SEQ_START_MEASURE > ram_251c)
			SEQ_START_MEASURE = ram_251c;
		else
			SEQ_START_MEASURE = 1;
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

extern unsigned char __near ram_26e2;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near PART_SELECT;
extern unsigned char PartDetect_LookupAndApply_Table[];
extern void PartSelect_UpdateDisplayState(void);
extern unsigned char Part_ReadVoiceByte(unsigned int, unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);

/* Part_DetectSingleVoiceType: when exactly one track is armed for recording, selects the part its voice type maps
   to (PartDetect_LookupAndApply_Table) and sets bit 0 of 0x26e2; else updates the part-select display. */
void Part_DetectSingleVoiceType(void)
{
	unsigned char n;
	unsigned char i;
	unsigned char f;
	unsigned char v;

	ram_26e2 &= ~0x01;
	n = 0;
	for (i = 1; i <= 16; i++) {
		if (SEQ_REC_TRACKS & (1 << (i - 1))) {
			n++;
			f = i;
		}
		if (n > 1)
			break;
	}
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
