/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m234.c (2026-11-19-29-p6-r46)
   sha256 18b7cd99d8b231daba0ba4aeddb6c2117e2469124ca962e1ec140c8521983203 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
