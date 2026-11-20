/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct mq;
typedef struct mq *mqp;
struct xfer;
typedef void (*cmdfn)(void);
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd20;
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
extern void SeqChan_StepCmd_Field1to2(void);
extern void SeqChan_StepCmd_Field2to3(void);
extern void SeqChan_StepCmd_Field4to5(void);
extern void SeqChan_StepCmd_Field5to6(void);
extern void SeqChan_XferStep_StyleImageBlk1(void);
extern void SeqChan_StepCmd_Field8to9(void);
extern void SeqChan_StepCmd_Field9to10(void);
extern void SeqChan_XferStep_AccompBlock1(void);
extern void SeqChan_XferStep_AccompBlock2(void);

/* cc900-name: MidiPkt_XferOnAccompBlocksBlk2=MidiPkt_XferOnAccompBlocksBlock2 */
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

void MidiPkt_XferOnAccompBlocksBlk2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 19) {
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcecL);
		SeqChan_XferStep_AccompBlock2();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
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

void MidiPkt_XferOnPanelMemBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 2) {
		MidiPkt_SetXferBlk_PanelMem((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field2to3();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 25);
}

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

void MidiPkt_XferOnStyleImageBlock2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 8) {
		MidiPkt_SetXferBlk_StyleImgTbl((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field8to9();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
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
