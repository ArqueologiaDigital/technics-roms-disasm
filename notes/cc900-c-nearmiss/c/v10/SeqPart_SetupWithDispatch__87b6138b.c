/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_6m236a.c (2026-11-19-49-p6-r49)
   sha256 87b6138bdb45916d24dfbb8d000e3ca72677895050a326ef02fa340329f3d656 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
