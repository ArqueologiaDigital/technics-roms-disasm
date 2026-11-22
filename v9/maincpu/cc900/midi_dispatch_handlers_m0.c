/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data_Helper11 MidiPkt_ArpConfigChain_Data_Helper12 MidiPkt_ArpConfigChain_Data_Helper13 MidiPkt_SendGroupEnd */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int AccWrap_ReturnZero(int);
extern void MidiPkt_SendGroupEnd(void);
extern void MidiPkt_ArpCfgChain_Helper11(void);
extern void MidiPkt_ArpCfgChain_Helper12(void);
extern void MidiPkt_ArpCfgChain_Helper13(void);
extern void MidiPkt_ArpCfgChain_Join(void);

/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
/* cc900-name: MidiPkt_ArpCfgChain_Helper11=MidiPkt_ArpConfigChain_Data_Helper11 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper12=MidiPkt_ArpConfigChain_Data_Helper12 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper13=MidiPkt_ArpConfigChain_Data_Helper13 */
void MidiPkt_ArpCfgChain_Join(void)
{
	if (AccWrap_ReturnZero(4) != -1) {
		MidiPkt_ArpCfgChain_Helper11();
		MidiPkt_ArpCfgChain_Helper12();
		MidiPkt_ArpCfgChain_Helper13();
		MidiPkt_SendGroupEnd();
	}
}

/* cc900-module: MidiPkt_RecoverIfXferAborted MidiTable_DispatchHelper MidiTable_FlushArpNotes SeqChan_StepCmd_Field1to2 SeqChan_StepCmd_Field2to3 SeqChan_StepCmd_Field4to5 SeqChan_StepCmd_Field5to6 SeqChan_StepCmd_Field8to9 SeqChan_StepCmd_Field9to10 SeqChan_XferStep_AccompBlock1 SeqChan_XferStep_AccompBlock2 SeqChan_XferStep_StyleImageBlock1 */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bd18;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MidiTable_DispatchHelper(void);
extern void MidiChan_ClearAllStates(void);
extern void SeqAlt_ProcessAndFinalize(void);
extern void MidiPkt_RecoverIfXferAborted(void);
extern void MidiPkt_XferShowResult(void);
extern void MidiPkt_ArpChordHandler(void);
struct xfer;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_PreparePanelReceive(void);
extern void MidiPkt_SetXferTotal_Panel(struct xfer *);
extern void MidiPkt_SetXferBlock_LivePanel(struct xfer *);
extern void SeqChan_StepCmd_Field1to2(void);
extern void MidiPkt_ArpExtHandler_A(void);
extern void MidiPkt_SetXferLengthFromMsg(void);
extern void MidiPkt_SetXferBlk_StyleImgPool(struct xfer *);
extern void SeqChan_StepCmd_Field9to10(void);
extern void MidiPkt_ArpExtHandler_G(void);
extern unsigned char __near ram_bd20;
extern unsigned char SysEx_Msg_35C4[];
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void MidiPkt_XferAnswerMsg21(void);
extern void MidiPkt_SetXferBlk_AccompBank(struct xfer *);
extern void SeqChan_XferStep_AccompBlock2(void);
extern void MidiPkt_XferOnAccompBlocksBlk2(void);
extern void MidiPkt_PrepAccompBlocksReceive(void);
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompArea(struct xfer *);
extern void SeqChan_XferStep_AccompBlock1(void);
extern void MidiPkt_XferOnAccompBlocksStart(void);
extern void MidiPkt_SetXferBlk_PanelMem(struct xfer *);
extern void SeqChan_StepCmd_Field2to3(void);
extern void MidiPkt_XferOnPanelMemBlock(void);
extern void MidiPkt_SetXferBlk_SoundRamData(struct xfer *);
extern void SeqChan_StepCmd_Field5to6(void);
extern void MidiPkt_XferOnSoundRamDataBlock(void);
extern void MidiPkt_SetXferTotal_SoundRam(struct xfer *);
extern void MidiPkt_SetXferBlock_SoundRamId(struct xfer *);
extern void SeqChan_StepCmd_Field4to5(void);
extern void MidiPkt_XferOnSoundRamStart(void);
extern void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *);
extern void SeqChan_StepCmd_Field8to9(void);
extern void MidiPkt_XferOnStyleImageBlock2(void);
extern void MidiPkt_PrepStyleImageReceive(void);
extern void MidiPkt_SetXferTotal_StyleImage(struct xfer *);
extern void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *);
extern void SeqChan_XferStep_StyleImageBlk1(void);
extern void MidiPkt_XferOnStyleImageStart(void);

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
/* cc900-name: MidiPkt_SetXferBlk_StyleImgPool=MidiPkt_SetXferBlock_StyleImagePool */
void MidiPkt_ArpExtHandler_G(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 9) {
		MidiPkt_SetXferBlk_StyleImgPool((struct xfer *)0xbcecL);
		MidiPkt_SetXferLengthFromMsg();
		SeqChan_StepCmd_Field9to10();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
}
void MidiPkt_XferAnswerMsg21(void)
{
	if (ram_bd20 == 0) {
		ram_bd20 = 1;
		SeqBuf_FlushNoteOffs(SysEx_Msg_35C4, 7);
	}
}
/* cc900-name: MidiPkt_XferOnAccompBlocksBlk2=MidiPkt_XferOnAccompBlocksBlock2 */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
void MidiPkt_XferOnAccompBlocksBlk2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 19) {
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcecL);
		SeqChan_XferStep_AccompBlock2();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
}
/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_PrepAccompBlocksReceive=MidiPkt_PrepareAccompBlocksReceive */
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
/* cc900-name: MidiPkt_SetXferBlk_PanelMem=MidiPkt_SetXferBlock_PanelMemories */
void MidiPkt_XferOnPanelMemBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 2) {
		MidiPkt_SetXferBlk_PanelMem((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field2to3();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 25);
}
/* cc900-name: MidiPkt_SetXferBlk_SoundRamData=MidiPkt_SetXferBlock_SoundRamData */
void MidiPkt_XferOnSoundRamDataBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 5) {
		MidiPkt_SetXferBlk_SoundRamData((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field5to6();
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
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
void MidiPkt_XferOnStyleImageBlock2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 8) {
		MidiPkt_SetXferBlk_StyleImgTbl((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field8to9();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
}
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_PrepStyleImageReceive=MidiPkt_PrepareStyleImageReceive */
/* cc900-name: SeqChan_XferStep_StyleImageBlk1=SeqChan_XferStep_StyleImageBlock1 */
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

/* cc900-module: SeqChan_StepCmd_Field13Write */
typedef void (*cmdfn)(void);
extern cmdfn SeqChan_StepCmdHandlers[];
extern void MidiPkt_XferOnDataPacket(void);
extern unsigned char __near ram_bd1c;
extern cmdfn SeqChan_WriteFieldHandlers[];
extern void MidiPkt_XferOnGroupEnd(void);
extern void MidiPkt_SetXferBlk_SeqEvents(struct xfer *);
extern void SeqChan_StepCmd_Field13Write(void);
extern void MidiPkt_XferOnSeqEventBlock(void);
extern void SeqChan_DefaultHandler(void);
extern void SeqChan_ProcessStepCmd(void);
extern void MidiPkt_UnpackNibblesToXfer(void);
extern void SeqChan_StepCmd_Field20to21(void);
extern void TmFlash_BulkTransferToSubCPU(void);
extern unsigned char __near MIDIPKT_RX_GROUPS;
extern void SeqChan_WriteField_Data_A(void);
extern void SeqChan_WriteField_Data_B(void);
extern void SeqChan_WriteField_Data_C(void);
extern void SeqChan_WriteField_Data_D(void);
extern void SeqChan_WriteField_Data_E(void);
extern void SeqChan_XferStep_CurrentSong(void);
extern void SeqChan_XferStep_SongSlots(void);

void MidiPkt_XferOnDataPacket(void)
{
	unsigned char n;

	n = SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3);
	if (n < 22)
		SeqChan_StepCmdHandlers[n]();
}
void MidiPkt_XferOnGroupEnd(void)
{
	unsigned char n;

	n = ((unsigned char *)MIDISEQ_SPARE_BUF_PTR)[3];
	if (n < 22) {
		SeqChan_WriteFieldHandlers[n]();
		ram_bd1c &= ~0x80;
	}
}
/* cc900-name: MidiPkt_SetXferBlk_SeqEvents=MidiPkt_SetXferBlock_SeqEvents */
void MidiPkt_XferOnSeqEventBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 13) {
		MidiPkt_SetXferBlk_SeqEvents((struct xfer *)0xbcecL);
		MidiPkt_SetXferLengthFromMsg();
		SeqChan_StepCmd_Field13Write();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 28);
}
void SeqChan_DefaultHandler(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 31);
}
void SeqChan_ProcessStepCmd(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 19);
}
void SeqChan_StepCmd_Field13Write(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 13);
	if (AccWrap_ReturnZero(4) != 0xffff)
		MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 14);
}
void SeqChan_StepCmd_Field1to2(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 1);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 2);
}
void SeqChan_StepCmd_Field20to21(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 20);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 21);
}
void SeqChan_StepCmd_Field2to3(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 2);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 3);
}
void SeqChan_StepCmd_Field4to5(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 4);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 5);
}
void SeqChan_StepCmd_Field5to6(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 5);
	MidiPkt_UnpackNibblesToXfer();
	TmFlash_BulkTransferToSubCPU();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 6);
}
void SeqChan_StepCmd_Field8to9(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 8);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 9);
}
void SeqChan_StepCmd_Field9to10(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 9);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 10);
}
void SeqChan_WriteField_Data_A(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 0);
	MIDIPKT_RX_GROUPS |= 0x80;
}
void SeqChan_WriteField_Data_B(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 0);
	MIDIPKT_RX_GROUPS |= 0x40;
}
void SeqChan_WriteField_Data_C(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 0);
	MIDIPKT_RX_GROUPS |= 0x20;
}
void SeqChan_WriteField_Data_D(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 0);
	MIDIPKT_RX_GROUPS |= 0x10;
}
void SeqChan_WriteField_Data_E(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 0);
	MIDIPKT_RX_GROUPS |= 0x04;
}
void SeqChan_XferStep_AccompBlock1(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 18);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 19);
}
void SeqChan_XferStep_AccompBlock2(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 19);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 20);
}
void SeqChan_XferStep_CurrentSong(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 11);
	if (AccWrap_ReturnZero(4) != 0xffff)
		MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 12);
}
void SeqChan_XferStep_SongSlots(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 12);
	if (AccWrap_ReturnZero(4) != 0xffff)
		MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 13);
}
/* cc900-name: SeqChan_XferStep_StyleImageBlk1=SeqChan_XferStep_StyleImageBlock1 */
void SeqChan_XferStep_StyleImageBlk1(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 7);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) == 0)
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 8);
}
