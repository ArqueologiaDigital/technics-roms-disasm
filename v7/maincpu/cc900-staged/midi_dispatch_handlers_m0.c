/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_RecoverIfXferAborted MidiTable_DispatchHelper MidiTable_FlushArpNotes SeqChan_StepCmd_Field1to2 SeqChan_StepCmd_Field2to3 SeqChan_StepCmd_Field4to5 SeqChan_StepCmd_Field5to6 SeqChan_StepCmd_Field8to9 SeqChan_StepCmd_Field9to10 SeqChan_XferStep_AccompBlock1 SeqChan_XferStep_AccompBlock2 SeqChan_XferStep_StyleImageBlock1 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char __near ram_bc7c;
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

void MidiPkt_ArpChordHandler(void)
{
	if (CURRENT_TITLE == 87 && SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 0) >= 7) {
		ram_bc7c |= 0x10;
		MidiChan_ClearAllStates();
		goto dispatch;
		for (;;) {
			if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) != 0) {
				ram_bc7c &= ~0x10;
				break;
			}
			SeqAlt_ProcessAndFinalize();
dispatch:
			MidiTable_DispatchHelper();
			if (!(ram_bc7c & 0x10))
				break;
		}
		MidiPkt_RecoverIfXferAborted();
		MidiPkt_XferShowResult();
	}
	ram_bc7c &= ~0x10;
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


/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */

/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_PrepAccompBlocksReceive=MidiPkt_PrepareAccompBlocksReceive */

/* cc900-name: MidiPkt_SetXferBlk_PanelMem=MidiPkt_SetXferBlock_PanelMemories */

/* cc900-name: MidiPkt_SetXferBlk_SoundRamData=MidiPkt_SetXferBlock_SoundRamData */


/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */

/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_PrepStyleImageReceive=MidiPkt_PrepareStyleImageReceive */
/* cc900-name: SeqChan_XferStep_StyleImageBlk1=SeqChan_XferStep_StyleImageBlock1 */
