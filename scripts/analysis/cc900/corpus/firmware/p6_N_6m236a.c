/* lane_p6 helper N, round 6, form a: module 236 (sequencer/sequencer_engine.s), new function.
   SeqPart_SetupWithDispatch: with the operation's part count (0xce5) at most 15, flags in 0x2879 whether the
   source / destination track is a drum track (SEQ_TRACK_ASSIGN type 12), runs the event loop for count + 1 parts
   and clears the flags again.  The flag clears as in the built SeqPart_ByteBlockA95A_Code_Helper, the track index
   as in the built SeqPart_AllocNewEntry (cc900/sequencer_engine_m236.c).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_EventLoop */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_2879;
extern unsigned char __near ram_ce5;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern void SeqVoice_SetDefaultParams(void);
extern void SeqVoice_InitReturnZero(void);
extern void SeqPart_EventLoop(unsigned int);

void SeqPart_SetupWithDispatch(void)
{
	SEQ_ERROR_CODE = 0;
	ram_2879 &= ~0x01;
	ram_2879 &= ~0x02;
	SeqVoice_SetDefaultParams();
	if (ram_ce5 > 15) {
		SeqVoice_InitReturnZero();
		return;
	}
	if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)] == 12)
		ram_2879 |= 0x01;
	if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)] == 12)
		ram_2879 |= 0x02;
	SeqPart_EventLoop((unsigned char)(ram_ce5 + 1));
	SeqVoice_InitReturnZero();
	ram_2879 &= ~0x01;
	ram_2879 &= ~0x02;
}
