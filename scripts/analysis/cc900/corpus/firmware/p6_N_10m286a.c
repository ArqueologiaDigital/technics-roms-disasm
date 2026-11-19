/* lane_p6 helper N, round 10, form a: module 286 (midi/midi_dispatch_handlers.s), new functions: the rest of the
   MIDI bulk-dump sender family of round 9's MidiPkt_ArpConfigChain_Data_Helper8 .. 13.
   - MidiPkt_SendBlock_{LivePanel, PanelMemories, SoundRamId, SoundRamData, AccompAreaHeader, AccompBankTables,
     AccompBlockPool}: one block each (channel parameter N, the built / probed MidiPkt_SetXferBlock_* at 0xbccc,
     the block's SysEx header).  Bodies inside the `== 0` test (the ROM's final `call; ret`).
   - MidiPkt_SendGroup_{Panel, SoundRam, StyleImage, AccompBlocks}: the groups; SoundRam / StyleImage only when
     the area exists (AccWrap_ReturnZero != -1, calls inside the test), Panel / AccompBlocks end in a tail jump.
   - MidiPkt_ArpConfigChain_Data: all groups, then the join (tail jump).
   - MidiPkt_SendGroupEnd: bumps the block counter (byte 3 of the record at 0xbcb4) and sends the group end.
   - SysEx_FinishBulkSend: the end message, and the final message when field 4 is 24 (one shared send call).
   cc900-options: -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data_Helper10 MidiPkt_ArpConfigChain_Data_Helper8 MidiPkt_ArpConfigChain_Data_Helper9 MidiPkt_ArpConfigChain_Data_Join MidiPkt_SendBlock_AccompAreaHeader MidiPkt_SendBlock_AccompBankTables MidiPkt_SendBlock_AccompBlockPool MidiPkt_SendBlock_LivePanel MidiPkt_SendBlock_PanelMemories MidiPkt_SendBlock_SoundRamData MidiPkt_SendBlock_SoundRamId MidiPkt_SendGroupEnd MidiPkt_SendGroup_AccompBlocks MidiPkt_SendGroup_Panel MidiPkt_SendGroup_SoundRam MidiPkt_SendGroup_StyleImage */
/* cc900-name: MidiPkt_ArpCfgChain_Helper8=MidiPkt_ArpConfigChain_Data_Helper8 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper9=MidiPkt_ArpConfigChain_Data_Helper9 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper10=MidiPkt_ArpConfigChain_Data_Helper10 */
/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
/* cc900-name: MidiPkt_SendBlk_AccompAreaHdr=MidiPkt_SendBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SendBlk_AccompBankTbls=MidiPkt_SendBlock_AccompBankTables */
/* cc900-name: MidiPkt_SendBlk_AccompBlockPool=MidiPkt_SendBlock_AccompBlockPool */
/* cc900-name: MidiPkt_SendBlk_PanelMemories=MidiPkt_SendBlock_PanelMemories */
/* cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
/* cc900-name: MidiPkt_SetXferBlk_AccompPool=MidiPkt_SetXferBlock_AccompBlockPool */

struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char *__near ram_bcb4;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(unsigned char *, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_Pack21BitValue(void);
extern void ArpQueue_ProcessAndSort_Data(void);
extern void MidiStream_PrevBankCheck(void);
extern int AccWrap_ReturnZero(int);
extern void MidiPkt_SetXferBlock_LivePanel(struct xfer *);
extern void MidiPkt_SetXferBlock_PanelMemories(struct xfer *);
extern void MidiPkt_SetXferBlock_SoundRamId(struct xfer *);
extern void MidiPkt_SetXferBlock_SoundRamData(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompArea(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompBank(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompPool(struct xfer *);
extern unsigned char SysEx_TechMsg_35E2[];
extern unsigned char SysEx_TechMsg_35EE[];
extern unsigned char SysEx_TechMsg_35FA[];
extern unsigned char SysEx_TechMsg_3606[];
extern unsigned char SysEx_TechMsg_3656[];
extern unsigned char SysEx_TechMsg_3662[];
extern unsigned char SysEx_TechMsg_366E[];
extern unsigned char SysEx_Msg_35A0[];
extern unsigned char SysEx_Msg_35A6[];
extern unsigned char SysEx_Msg_35AC[];
extern void MidiPkt_ArpCfgChain_Helper8(void);
extern void MidiPkt_ArpCfgChain_Helper9(void);
extern void MidiPkt_ArpCfgChain_Helper10(void);
extern void MidiPkt_ArpCfgChain_Join(void);
extern void MidiPkt_SendBlock_LivePanel(void);
extern void MidiPkt_SendBlk_PanelMemories(void);
extern void MidiPkt_SendBlock_SoundRamId(void);
extern void MidiPkt_SendBlock_SoundRamData(void);
extern void MidiPkt_SendBlk_AccompAreaHdr(void);
extern void MidiPkt_SendBlk_AccompBankTbls(void);
extern void MidiPkt_SendBlk_AccompBlockPool(void);
extern void MidiPkt_SendGroupEnd(void);
extern void MidiPkt_SendGroup_Panel(void);
extern void MidiPkt_SendGroup_SoundRam(void);
extern void MidiPkt_SendGroup_StyleImage(void);
extern void MidiPkt_SendGrp_AccompBlocks(void);

void MidiPkt_ArpConfigChain_Data(void)
{
	MidiPkt_SendGroup_Panel();
	MidiPkt_SendGroup_SoundRam();
	MidiPkt_SendGrp_AccompBlocks();
	MidiPkt_SendGroup_StyleImage();
	MidiPkt_ArpCfgChain_Join();
}

void MidiPkt_SendGroup_Panel(void)
{
	MidiPkt_SendBlock_LivePanel();
	MidiPkt_SendBlk_PanelMemories();
	MidiPkt_SendGroupEnd();
}

void MidiPkt_SendBlock_LivePanel(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 1);
		MidiPkt_SetXferBlock_LivePanel((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35E2, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendBlk_PanelMemories(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 2);
		MidiPkt_SetXferBlock_PanelMemories((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35EE, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendGroup_SoundRam(void)
{
	if (AccWrap_ReturnZero(1) != -1) {
		MidiPkt_SendBlock_SoundRamId();
		MidiPkt_SendBlock_SoundRamData();
		MidiPkt_SendGroupEnd();
	}
}

void MidiPkt_SendBlock_SoundRamId(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 4);
		MidiPkt_SetXferBlock_SoundRamId((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35FA, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendBlock_SoundRamData(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 5);
		MidiPkt_SetXferBlock_SoundRamData((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3606, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendGroup_StyleImage(void)
{
	if (AccWrap_ReturnZero(3) != -1) {
		MidiPkt_ArpCfgChain_Helper8();
		MidiPkt_ArpCfgChain_Helper9();
		MidiPkt_ArpCfgChain_Helper10();
		MidiPkt_SendGroupEnd();
	}
}

void MidiPkt_SendGrp_AccompBlocks(void)
{
	MidiPkt_SendBlk_AccompAreaHdr();
	MidiPkt_SendBlk_AccompBankTbls();
	MidiPkt_SendBlk_AccompBlockPool();
	MidiPkt_SendGroupEnd();
}

void MidiPkt_SendBlk_AccompAreaHdr(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 18);
		MidiPkt_SetXferBlk_AccompArea((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3656, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendBlk_AccompBankTbls(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 19);
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3662, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendBlk_AccompBlockPool(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 20);
		MidiPkt_SetXferBlk_AccompPool((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_366E, 9);
		ArpQueue_Pack21BitValue();
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_SendGroupEnd(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		ram_bcb4[3]++;
		SeqBuf_FlushNoteOffs(SysEx_Msg_35A0, 5);
		MidiStream_PrevBankCheck();
	}
}

void SysEx_FinishBulkSend(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		SeqBuf_FlushNoteOffs(SysEx_Msg_35A6, 5);
		MidiStream_PrevBankCheck();
		if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 24)
			SeqBuf_FlushNoteOffs(SysEx_Msg_35AC, 5);
	} else {
		if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 24)
			SeqBuf_FlushNoteOffs(SysEx_Msg_35AC, 5);
	}
}
