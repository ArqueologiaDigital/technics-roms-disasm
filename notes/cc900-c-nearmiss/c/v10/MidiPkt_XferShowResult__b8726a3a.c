/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_N_11m286a.c (2026-11-19-83-p6-r56)
   sha256 b8726a3a71982a43615d796ffa19dae43be9729704e50c7da2beb12b58280117 (tar-sha256); compiled at -O3 -Xr */
/* lane_p6 helper N, round 11, form a: module 286 (midi/midi_dispatch_handlers.s), MidiPkt_ArpConfigChain_Data
   Helper8 / 9 / 10 again (p6-r54: "cannot resolve .MidiPkt_SetXferBlock_StyleImage" -- the 31-character cut that
   StyleImageHeader / StyleImageTables / StyleImagePool share): each callee under its own short C name.
   Below them, new functions of the module:
   - SysEx_Send{All, StyleImage, Sequencer, SoundMemory, PanelMemory, MspUser}Data: set the total transfer at
     0xbcbc (a numeric pointer) and send the matching group (round 10's matched senders; tail jumps), the all-data
     one between setting and clearing bit 3 of 0xbd18; SysEx_SendNothing is empty.
   - MidiPkt_XferShowResult: after the dual event, shows "completed" (field 4 = 0), nothing (34) or the error
     message for the code, then a playback no-op when bit 1 of 0xbd18 is set.  A switch with case 0 written first
     (the ROM compares 34 first), the error as its default.
   - MidiPkt_XferShowCompleted / _XferShowNothing / _XferShowErrorMessage.
   cc900-options: -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data MidiPkt_ArpConfigChain_Data_Join MidiPkt_SendGroup_AccompBlocks MidiPkt_SendGroup_Panel MidiPkt_SendGroup_SoundRam MidiPkt_SendGroup_StyleImage MidiPkt_XferShowCompleted MidiPkt_XferShowErrorMessage MidiPkt_XferShowNothing */
/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
/* cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks */
/* cc900-name: MidiPkt_SetXferTotal_StyleImg=MidiPkt_SetXferTotal_StyleImage */
/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
/* cc900-name: MidiPkt_XferShowErrorMsg=MidiPkt_XferShowErrorMessage */
/* cc900-name: MidiPkt_ArpCfgChain_Helper8=MidiPkt_ArpConfigChain_Data_Helper8 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper9=MidiPkt_ArpConfigChain_Data_Helper9 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper10=MidiPkt_ArpConfigChain_Data_Helper10 */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgPool=MidiPkt_SetXferBlock_StyleImagePool */

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
extern void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *);
extern void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *);
extern void MidiPkt_SetXferBlk_StyleImgPool(struct xfer *);
extern unsigned char SysEx_TechMsg_3612[];
extern unsigned char SysEx_TechMsg_361E[];
extern unsigned char SysEx_TechMsg_362A[];

void MidiPkt_ArpCfgChain_Helper8(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 7);
		MidiPkt_SetXferBlk_StyleImgHdr((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3612, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Helper9(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 8);
		MidiPkt_SetXferBlk_StyleImgTbl((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_361E, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Helper10(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 9);
		MidiPkt_SetXferBlk_StyleImgPool((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_362A, 9);
		ArpQueue_Pack21BitValue();
		ArpQueue_ProcessAndSort_Data();
	}
}

#define TT_MESAGE 0xee
extern unsigned char __near ram_bd18;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char MidiRx_PartLookup_ByteMap[];
extern void UI_InterruptTitleByIndex(unsigned int);
extern void ParaLoadOpt_PostDualEvent(int);
extern void SeqStep_PlaybackNop(void);
extern void MidiPkt_SetXferTotal_All(struct xfer *);
extern void MidiPkt_SetXferTotal_StyleImg(struct xfer *);
extern void MidiPkt_SetXferTotal_SeqData(struct xfer *);
extern void MidiPkt_SetXferTotal_SoundRam(struct xfer *);
extern void MidiPkt_SetXferTotal_Panel(struct xfer *);
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *);
extern void MidiPkt_ArpConfigChain_Data(void);
extern void MidiPkt_ArpCfgChain_Join(void);
extern void MidiPkt_SendGroup_StyleImage(void);
extern void MidiPkt_SendGroup_SoundRam(void);
extern void MidiPkt_SendGroup_Panel(void);
extern void MidiPkt_SendGrp_AccompBlocks(void);
extern void MidiPkt_XferShowCompleted(void);
extern void MidiPkt_XferShowNothing(void);
extern void MidiPkt_XferShowErrorMsg(void);

void MidiPkt_XferShowResult(void)
{
	ParaLoadOpt_PostDualEvent(0);
	switch (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4)) {
	case 0:
		MidiPkt_XferShowCompleted();
		break;
	case 34:
		MidiPkt_XferShowNothing();
		break;
	default:
		MidiPkt_XferShowErrorMsg();
		break;
	}
	if (ram_bd18 & 0x02)
		SeqStep_PlaybackNop();
}

void MidiPkt_XferShowCompleted(void)
{
	GLOBAL_ERROR_CODE = 35;
	UI_InterruptTitleByIndex(TT_MESAGE);
}

void MidiPkt_XferShowNothing(void)
{
}

void MidiPkt_XferShowErrorMsg(void)
{
	GLOBAL_ERROR_CODE = MidiRx_PartLookup_ByteMap[SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4)];
	UI_InterruptTitleByIndex(TT_MESAGE);
}

void SysEx_SendAllData(void)
{
	ram_bd18 |= 0x08;
	MidiPkt_SetXferTotal_All((struct xfer *)0xbcbcL);
	MidiPkt_ArpConfigChain_Data();
	ram_bd18 &= ~0x08;
}

void SysEx_SendStyleImageData(void)
{
	MidiPkt_SetXferTotal_StyleImg((struct xfer *)0xbcbcL);
	MidiPkt_SendGroup_StyleImage();
}

void SysEx_SendSequencerData(void)
{
	MidiPkt_SetXferTotal_SeqData((struct xfer *)0xbcbcL);
	MidiPkt_ArpCfgChain_Join();
}

void SysEx_SendSoundMemoryData(void)
{
	MidiPkt_SetXferTotal_SoundRam((struct xfer *)0xbcbcL);
	MidiPkt_SendGroup_SoundRam();
}

void SysEx_SendPanelMemoryData(void)
{
	MidiPkt_SetXferTotal_Panel((struct xfer *)0xbcbcL);
	MidiPkt_SendGroup_Panel();
}

void SysEx_SendNothing(void)
{
}

void SysEx_SendMspUserData(void)
{
	MidiPkt_SetXferTotal_AccompBlk((struct xfer *)0xbcbcL);
	MidiPkt_SendGrp_AccompBlocks();
}
