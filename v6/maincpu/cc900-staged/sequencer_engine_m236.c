/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqPart_EventLoop */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char __near ram_285d;
extern unsigned char __near ram_ce5;
extern unsigned char __near SEQ_TRACK;
extern unsigned char __near SEQ_OP_DEST_TRACK;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern void SeqVoice_SetDefaultParams(void);
extern void SeqVoice_InitReturnZero(void);
extern void SeqPart_EventLoop(unsigned int);
extern void SeqPart_SetupWithDispatch(void);

void SeqPart_SetupWithDispatch(void)
{
	SEQ_ERROR_CODE = 0;
	ram_285d &= ~0x01;
	ram_285d &= ~0x02;
	SeqVoice_SetDefaultParams();
	if (ram_ce5 > 15) {
		SeqVoice_InitReturnZero();
		return;
	}
	if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_TRACK - 1)] == 12)
		ram_285d |= 0x01;
	if (SEQ_TRACK_ASSIGN[(unsigned char)(SEQ_OP_DEST_TRACK - 1)] == 12)
		ram_285d |= 0x02;
	SeqPart_EventLoop((unsigned char)(ram_ce5 + 1));
	SeqVoice_InitReturnZero();
	ram_285d &= ~0x01;
	ram_285d &= ~0x02;
}
