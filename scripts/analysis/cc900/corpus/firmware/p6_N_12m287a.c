/* lane_p6 helper N, round 12, form a: module 287 (midi/midi_dispatch_handlers.s), new functions: the receive
   side of the bulk-dump family (the matched senders and SetXfer functions are its siblings).
   - MidiPkt_XferOn* / MidiPkt_ArpExtHandler_A / _G / _J: when field 3 of the spare buffer is the expected block
     number, set up the receive transfer(s) (totals at 0xbcdc, block at 0xbcec, numeric pointers) and step the
     command (tail jump); else report channel parameter 25 / 26 / 27 / 30 (tail jump).  if / else: both ends are
     tail jumps in the ROM.
   - MidiTable_DispatchHelper: dispatches the active buffer's command (< 0x27) through SeqChan_CommandDispatch_Table,
     then flushes and updates; MidiTable_FlushArpNotes: sends the end message for the command state;
     MidiPkt_ArpChordHandler: the receive loop of the bulk-dump title (87).
   - MidiPkt_XferAnswerMsg21 / MidiPkt_HandleCmdCode01: the answer message, the command-1 fields.
   Calls that end an `if` without `else` are written inside it (the ROM's `call; ret`).
   cc900-options: -Xr
*/
/* cc900-module: MidiPkt_RecoverIfXferAborted MidiTable_DispatchHelper MidiTable_FlushArpNotes SeqChan_StepCmd_Field1to2 SeqChan_StepCmd_Field2to3 SeqChan_StepCmd_Field4to5 SeqChan_StepCmd_Field5to6 SeqChan_StepCmd_Field8to9 SeqChan_StepCmd_Field9to10 SeqChan_XferStep_AccompBlock1 SeqChan_XferStep_AccompBlock2 SeqChan_XferStep_StyleImageBlock1 */
/* cc900-name: MidiPkt_XferOnAccompBlocksBlk2=MidiPkt_XferOnAccompBlocksBlock2 */
/* cc900-name: MidiPkt_SetXferBlk_PanelMem=MidiPkt_SetXferBlock_PanelMemories */
/* cc900-name: MidiPkt_SetXferBlk_SoundRamData=MidiPkt_SetXferBlock_SoundRamData */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgPool=MidiPkt_SetXferBlock_StyleImagePool */
/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
/* cc900-name: MidiPkt_SetXferBlk_AccompPool=MidiPkt_SetXferBlock_AccompBlockPool */
/* cc900-name: MidiPkt_PrepStyleImageReceive=MidiPkt_PrepareStyleImageReceive */
/* cc900-name: MidiPkt_PrepAccompBlocksReceive=MidiPkt_PrepareAccompBlocksReceive */
/* cc900-name: SeqChan_XferStep_StyleImageBlk1=SeqChan_XferStep_StyleImageBlock1 */

struct mq;
typedef struct mq *mqp;
struct xfer;
typedef void (*cmdfn)(void);
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd20;
extern unsigned char __near ram_bc68;
extern unsigned char __near ram_bc69;
extern unsigned char __near ram_bc6a;
extern unsigned char __near CURRENT_TITLE;
extern cmdfn SeqChan_CommandDispatch_Table[];
extern unsigned char SysEx_Msg_3594[];
extern unsigned char SysEx_Msg_359A[];
extern unsigned char SysEx_Msg_35B2[];
extern unsigned char SysEx_Msg_35C4[];
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_SwapBuffers(void);
extern void MidiTable_PreDispatchNullRet(void);
extern void MidiSeq_UpdateAllParams(void);
extern void MidiTable_NullRet(void);
extern void MidiTable_FlushArpNotes(void);
extern void MidiTable_DispatchHelper(void);
extern void MidiChan_ClearAllStates(void);
extern void SeqAlt_ProcessAndFinalize(void);
extern void MidiPkt_RecoverIfXferAborted(void);
extern void MidiPkt_XferShowResult(void);
extern void MidiPkt_PreparePanelReceive(void);
extern void MidiPkt_PrepStyleImageReceive(void);
extern void MidiPkt_PrepAccompBlocksReceive(void);
extern void MidiPkt_SetXferLengthFromMsg(void);
extern void MidiPkt_SetXferTotal_Panel(struct xfer *);
extern void MidiPkt_SetXferTotal_SoundRam(struct xfer *);
extern void MidiPkt_SetXferTotal_StyleImage(struct xfer *);
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *);
extern void MidiPkt_SetXferBlock_LivePanel(struct xfer *);
extern void MidiPkt_SetXferBlk_PanelMem(struct xfer *);
extern void MidiPkt_SetXferBlock_SoundRamId(struct xfer *);
extern void MidiPkt_SetXferBlk_SoundRamData(struct xfer *);
extern void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *);
extern void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *);
extern void MidiPkt_SetXferBlk_StyleImgPool(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompArea(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompBank(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompPool(struct xfer *);
extern void SeqChan_StepCmd_Field1to2(void);
extern void SeqChan_StepCmd_Field2to3(void);
extern void SeqChan_StepCmd_Field4to5(void);
extern void SeqChan_StepCmd_Field5to6(void);
extern void SeqChan_XferStep_StyleImageBlk1(void);
extern void SeqChan_StepCmd_Field8to9(void);
extern void SeqChan_StepCmd_Field9to10(void);
extern void SeqChan_XferStep_AccompBlock1(void);
extern void SeqChan_XferStep_AccompBlock2(void);
extern void SeqChan_StepCmd_Field20to21(void);

void MidiPkt_ArpChordHandler(void)
{
	if (CURRENT_TITLE == 87 && SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 0) >= 7) {
		ram_bd18 |= 0x10;
		MidiChan_ClearAllStates();
		goto dispatch;
		for (;;) {
			if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) != 0) {
				ram_bd18 &= ~0x10;
				break;
			}
			SeqAlt_ProcessAndFinalize();
dispatch:
			MidiTable_DispatchHelper();
			if (!(ram_bd18 & 0x10))
				break;
		}
		MidiPkt_RecoverIfXferAborted();
		MidiPkt_XferShowResult();
	}
	ram_bd18 &= ~0x10;
}

void MidiTable_DispatchHelper(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MidiTable_PreDispatchNullRet();
		if (*(unsigned char *)MIDISEQ_ACTIVE_BUF_PTR < 0x27) {
			SeqChan_CommandDispatch_Table[*(unsigned char *)MIDISEQ_ACTIVE_BUF_PTR]();
			MidiTable_FlushArpNotes();
			MidiSeq_UpdateAllParams();
			MidiTable_NullRet();
		}
	}
}

void MidiTable_FlushArpNotes(void)
{
	unsigned char a;

	if (ram_bd18 & 0x80) {
		ArpQueue_SwapBuffers();
		a = ((unsigned char *)MIDISEQ_ACTIVE_BUF_PTR)[4];
		if (a == 0)
			SeqBuf_FlushNoteOffs(SysEx_Msg_3594, 5);
		else if (a == 0x16)
			SeqBuf_FlushNoteOffs(SysEx_Msg_35B2, 5);
		else
			SeqBuf_FlushNoteOffs(SysEx_Msg_359A, 5);
	}
}

void MidiPkt_XferAnswerMsg21(void)
{
	if (ram_bd20 == 0) {
		ram_bd20 = 1;
		SeqBuf_FlushNoteOffs(SysEx_Msg_35C4, 7);
	}
}

void MidiPkt_HandleCmdCode01(void)
{
	if (ram_bd20 == 1) {
		ram_bc68 = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 6);
		ram_bc69 = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 7);
		ram_bc6a = SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 8);
		ram_bd18 |= 0x80;
		ram_bd20 = 2;
	} else {
		((unsigned char *)MIDISEQ_ACTIVE_BUF_PTR)[4] = 0x18;
		ram_bd18 &= ~0x10;
	}
}

void MidiPkt_ArpExtHandler_A(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 0) {
		MidiPkt_PreparePanelReceive();
		MidiPkt_SetXferTotal_Panel((struct xfer *)0xbcdcL);
		MidiPkt_SetXferBlock_LivePanel((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field1to2();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 25);
}

void MidiPkt_XferOnPanelMemBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 2) {
		MidiPkt_SetXferBlk_PanelMem((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field2to3();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 25);
}

void MidiPkt_XferOnSoundRamStart(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 0) {
		MidiPkt_SetXferTotal_SoundRam((struct xfer *)0xbcdcL);
		MidiPkt_SetXferBlock_SoundRamId((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field4to5();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 26);
}

void MidiPkt_XferOnSoundRamDataBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 5) {
		MidiPkt_SetXferBlk_SoundRamData((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field5to6();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 25);
}

void MidiPkt_XferOnStyleImageStart(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 0) {
		MidiPkt_PrepStyleImageReceive();
		MidiPkt_SetXferTotal_StyleImage((struct xfer *)0xbcdcL);
		MidiPkt_SetXferBlk_StyleImgHdr((struct xfer *)0xbcecL);
		SeqChan_XferStep_StyleImageBlk1();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
}

void MidiPkt_XferOnStyleImageBlock2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 8) {
		MidiPkt_SetXferBlk_StyleImgTbl((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field8to9();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
}

void MidiPkt_ArpExtHandler_G(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 9) {
		MidiPkt_SetXferBlk_StyleImgPool((struct xfer *)0xbcecL);
		MidiPkt_SetXferLengthFromMsg();
		SeqChan_StepCmd_Field9to10();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
}

void MidiPkt_XferOnAccompBlocksStart(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 0) {
		MidiPkt_PrepAccompBlocksReceive();
		MidiPkt_SetXferTotal_AccompBlk((struct xfer *)0xbcdcL);
		MidiPkt_SetXferBlk_AccompArea((struct xfer *)0xbcecL);
		SeqChan_XferStep_AccompBlock1();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
}

void MidiPkt_XferOnAccompBlocksBlk2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 19) {
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcecL);
		SeqChan_XferStep_AccompBlock2();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
}

void MidiPkt_ArpExtHandler_J(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 20) {
		MidiPkt_SetXferBlk_AccompPool((struct xfer *)0xbcecL);
		MidiPkt_SetXferLengthFromMsg();
		SeqChan_StepCmd_Field20to21();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
}
