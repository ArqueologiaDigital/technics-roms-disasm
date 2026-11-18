/* Phase 6, lane_p6 helper J, round 5, module 234, form b: SeqPlay_HandleChannelSolo with the saved measure in a
   local (the ROM loads 0x251c once into WA for both the compare and the store); SeqEvt_ProcessBlock with an
   aggregate initializer {0, 0} (the template's bytes) so V4.23 emits its own template copy. */
/* cc900-name: SeqEvtPB_Init=SeqEvt_ProcessBlock_LocalInit */
/* cc900-module: Chan_SetActiveBit Part_ReadSubBlock32 Part_ReadVoiceWord SeqEvent_ProcessRhythm4Ch SeqPlay_InitStartState */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned int __near ram_251c;
extern unsigned char __near ram_2324;
extern unsigned char __near ram_2664;
extern unsigned char __near ram_28ae;
extern void NoteEditSy_SendModeScrollReset(void);
extern void SeqPlay_InitStartState(void);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void Audio_CheckSubsystemReady(void);

void SeqPlay_HandleChannelSolo(unsigned char ch)
{
	unsigned int m;

	if (SEQ_TRACK_MASK == 0) {
		if ((SEQ_CYCLE_FLAGS & 1) && SEQ_START_MEASURE > (m = ram_251c))
			SEQ_START_MEASURE = m;
		else
			SEQ_START_MEASURE = 1;
		NoteEditSy_SendModeScrollReset();
		if (SEQ_START_MEASURE == 1)
			SEQ_RTMCFG &= ~8;
		else
			SEQ_RTMCFG |= 8;
		SeqPlay_InitStartState();
	}
	if (ch == ram_2324 && (DEMO_CONTROL_FLAGS & 0x40)) {
		ram_28ae = ram_2664;
		ram_28ae |= 0x80;
	}
	Chan_SetActiveBit(ch, 1);
	Audio_CheckSubsystemReady();
}

struct cur4 { unsigned int blk; unsigned int ofs; };
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned char SeqEvent_ProcessRhythm4Ch(struct cur4 *);

int SeqEvt_ProcessBlock(unsigned char part)
{
	int n = 0;
	unsigned char go = 1;
	struct cur4 c = { 0, 0 };
	unsigned char r;

	r = Part_ReadSubBlock32(0, part);
	if (r != 16 && r != 13)
		return 0;
	c.blk = Part_ReadVoiceWord(0, part);
	c.ofs = 5;
	do {
		r = SeqEvent_ProcessRhythm4Ch(&c);
		if (r == 132)
			go = 0;
		else if (r == 130) {
			n = 0;
			go = 0;
		} else if (r == 129)
			n++;
	} while (go == 1);
	return n;
}
