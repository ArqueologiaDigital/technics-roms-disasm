/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SoundCtrl_SaveAndSendCmd_EE */   /* scripts/analysis/cc900/module_calls.py v10 */

#define MD_SEQ_REAL              0xb
extern void SeqPlay_SaveStateAndCleanup(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern unsigned char SeqStatus_CheckBit2(void);
extern void Part_WriteAllVoiceSubBlocks_A();
extern void Part_WriteAllVoiceSubBlocks_B();
extern void Part_WriteWord();
extern void Part_ReleaseVoicesForRange();
extern void Audio_CheckSubsystemReady(void);
extern void AccWrap_PositionClear(void);
extern void Part_DetectSingleVoiceType(void);
extern void UI_ChangeModeByIndex(unsigned int);
extern unsigned char __near ram_1d94;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near ram_28a6;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned char __near ram_26fc;
extern void MainExe_SequencerStop(void);

void MainExe_SequencerStop(void)
{
	ram_1d94 = 0;
	SeqPlay_SaveStateAndCleanup();
	CtrlPanel_SetIndicatorBit(0x4c);
	SEQ_CYCLE_FLAGS &= ~2;
	if (SeqStatus_CheckBit2() == 0) Part_WriteAllVoiceSubBlocks_A(0);
	else Part_WriteAllVoiceSubBlocks_B(0);
	Part_WriteWord(0, 0x50, 0xffff);
	Part_ReleaseVoicesForRange(0, 0x32);
	SEQ_TRACK_MASK = 0;
	Audio_CheckSubsystemReady();
	AccWrap_PositionClear();
	ram_28a6 &= ~1;
	SEQ_TRACK_MASK_COPY = 0;
	ram_26fc = 1;
	Part_DetectSingleVoiceType();
	UI_ChangeModeByIndex(MD_SEQ_REAL);
}

#define EVT_PARA_DRAW 0x1c0000fL
extern void ApDeliveryEvent(long, long, long);
extern long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_2788;
extern void NoteEditSy_SendGateCmd(void);
extern void NoteEditSy_SendScrollCmd1(void);
extern void NoteEditSy_SendScrollCmd5(void);
#define EVT_GRAPH_DRAW 0x1c80004L
extern void NoteEditSy_SendWidgetCmd0(void);
extern void NoteEditSy_SendWidgetCmd2(void);
extern unsigned char __near ram_2742;
extern void NoteEditSy_SendWidgetCmd3or4(void);

void NoteEditSy_SendGateCmd(void)
{
  ram_296a = ram_2788;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 4L);
}
void NoteEditSy_SendScrollCmd1(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 1L);
}
void NoteEditSy_SendScrollCmd5(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 5L);
}
void NoteEditSy_SendWidgetCmd0(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 0L);
}
void NoteEditSy_SendWidgetCmd2(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 2L);
}
void NoteEditSy_SendWidgetCmd3or4(void)
{
  long d = 3;
  if (ram_2742 & 1) d = 4;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, d);
}
