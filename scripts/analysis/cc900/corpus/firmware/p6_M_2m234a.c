/* Phase 6, lane_p6 helper M, round 2, module 234 (sequencer/sequencer_engine.s, a -O file), form a.
   SeqVoice_CountEventsInBar: walk the channel's data counting 0x81 marks; every ram_288e marks start a new bar (the
   result counts bars, from 1); 0x82 / 0x84 end the data (error 8); stops after ram_ce3 marks.  The ROM's entry test
   `cpw (ram_ce3),0` is -O3's copied loop test with n known 0.  Frame: k +0, r +2, n +4 (plain, declaration order).
   SeqPart_ConsumeTicksFromBuffer: advance a (block, position) cursor by ram_25da ticks; a block holds 0x100 - 5
   ticks after its 5-byte header (0xfb), blocks are chained through PartCtrl_ReadWord. */
/* cc900-module: PartCtrl_ReadWord PartCtrl_TestBit7 Part_ValidateVoiceChannel SeqData_AdvancePosition SeqData_ReadNextByte SeqTrack_ProcessControlBytes SeqVoice_SetDefaultParams SeqVoice_ValidateAndProcessState */

extern void SeqVoice_SetDefaultParams(void);
extern void Part_ValidateVoiceChannel(unsigned int);
extern void SeqVoice_ValidateAndProcessState(void);
extern void SeqTrack_ProcessControlBytes(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void SeqData_AdvancePosition(void);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_288d;
extern unsigned char __near ram_288e;
extern unsigned int __near ram_ce3;
extern unsigned long __near ram_25da;
extern int SeqVoice_CountEventsInBar(unsigned char ch);
extern void SeqPart_ConsumeTicksFromBuffer(unsigned int *blk, unsigned int *pos);

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

void SeqPart_ConsumeTicksFromBuffer(unsigned int *blk, unsigned int *pos)
{
	unsigned long room;
	unsigned long r;
	unsigned int b;

	room = (unsigned int)(0x100 - *pos);
	if (room > ram_25da) {
		*pos += ram_25da;
		return;
	}
	r = ram_25da - room;
	for (;;) {
		b = PartCtrl_ReadWord(*blk);
		if (b > 0x4d8) {
			SEQ_ERROR_CODE = 10;
			return;
		}
		*blk = b;
		if (PartCtrl_TestBit7(b) == 0) {
			SEQ_ERROR_CODE = 11;
			return;
		}
		if (r <= 0xfb) {
			*pos = r + 5;
			return;
		}
		r -= 0xfb;
	}
}
