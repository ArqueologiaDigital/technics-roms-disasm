/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v9/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 1f9373e79f12efdca5885479565839bb316abb0fe5a4af1cd75fe40c48008f08 (tar-sha256); compiled at -O3 -XS -Xr */
/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data MidiPkt_ArpConfigChain_Data_Helper10 MidiPkt_ArpConfigChain_Data_Helper8 MidiPkt_ArpConfigChain_Data_Helper9 MidiPkt_ArpConfigChain_Data_Join MidiPkt_SendBlock_AccompAreaHeader MidiPkt_SendBlock_AccompBankTables MidiPkt_SendBlock_AccompBlockPool MidiPkt_SendBlock_LivePanel MidiPkt_SendBlock_PanelMemories MidiPkt_SendBlock_SoundRamData MidiPkt_SendBlock_SoundRamId MidiPkt_SendGroupEnd MidiPkt_SendGroup_AccompBlocks MidiPkt_SendGroup_Panel MidiPkt_SendGroup_SoundRam MidiPkt_SendGroup_StyleImage MidiPkt_XferShowCompleted MidiPkt_XferShowErrorMessage MidiPkt_XferShowNothing */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void MidiPkt_SetXferBlk_StyleImgPool(struct xfer *);
extern unsigned char SysEx_TechMsg_362A[];
extern void MidiPkt_ArpCfgChain_Helper10(void);
extern void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *);
extern unsigned char SysEx_TechMsg_3612[];
extern void MidiPkt_ArpCfgChain_Helper8(void);
extern void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *);
extern unsigned char SysEx_TechMsg_361E[];
extern void MidiPkt_ArpCfgChain_Helper9(void);
#define TT_MESAGE 0xee
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(unsigned int);
extern void MidiPkt_XferShowCompleted(void);
extern unsigned char MidiRx_PartLookup_ByteMap[];
extern void MidiPkt_XferShowErrorMsg(void);
extern void MidiPkt_XferShowNothing(void);
extern unsigned char __near ram_bd18;
extern void ParaLoadOpt_PostDualEvent(int);
extern void SeqStep_PlaybackNop(void);
extern void MidiPkt_XferShowResult(void);
extern void MidiPkt_SetXferTotal_All(struct xfer *);
extern void MidiPkt_ArpConfigChain_Data(void);
extern void SysEx_SendAllData(void);
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *);
extern void MidiPkt_SendGrp_AccompBlocks(void);
extern void SysEx_SendMspUserData(void);
extern void SysEx_SendNothing(void);
extern void MidiPkt_SetXferTotal_Panel(struct xfer *);
extern void MidiPkt_SendGroup_Panel(void);
extern void SysEx_SendPanelMemoryData(void);
extern void MidiPkt_SetXferTotal_SeqData(struct xfer *);
extern void MidiPkt_ArpCfgChain_Join(void);
extern void SysEx_SendSequencerData(void);
extern void MidiPkt_SetXferTotal_SoundRam(struct xfer *);
extern void MidiPkt_SendGroup_SoundRam(void);
extern void SysEx_SendSoundMemoryData(void);
extern void MidiPkt_SetXferTotal_StyleImg(struct xfer *);
extern void MidiPkt_SendGroup_StyleImage(void);
extern void SysEx_SendStyleImageData(void);
extern void MidiPkt_SendBlk_AccompAreaHdr(void);
extern void MidiPkt_SendBlk_AccompBankTbls(void);
extern void MidiPkt_SendBlk_AccompBlockPool(void);
extern void MidiPkt_SendGroupEnd(void);
extern void MidiPkt_SendBlock_LivePanel(void);
extern void MidiPkt_SendBlk_PanelMemories(void);
extern int AccWrap_ReturnZero(int);
extern void MidiPkt_SendBlock_SoundRamId(void);
extern void MidiPkt_SendBlock_SoundRamData(void);
extern void MidiPkt_SetXferBlk_AccompArea(struct xfer *);
extern unsigned char SysEx_TechMsg_3656[];
extern void MidiPkt_SetXferBlk_AccompBank(struct xfer *);
extern unsigned char SysEx_TechMsg_3662[];
extern void MidiPkt_SetXferBlk_AccompPool(struct xfer *);
extern unsigned char SysEx_TechMsg_366E[];
extern void MidiPkt_SetXferBlock_LivePanel(struct xfer *);
extern unsigned char SysEx_TechMsg_35E2[];
extern void MidiPkt_SetXferBlock_PanelMemories(struct xfer *);
extern unsigned char SysEx_TechMsg_35EE[];
extern void MidiPkt_SetXferBlock_SoundRamData(struct xfer *);
extern unsigned char SysEx_TechMsg_3606[];
extern void MidiPkt_SetXferBlock_SoundRamId(struct xfer *);
extern unsigned char SysEx_TechMsg_35FA[];
extern void MidiStream_PrevBankCheck(void);
extern unsigned char SysEx_Msg_35A0[];

/* cc900-name: MidiPkt_ArpCfgChain_Helper10=MidiPkt_ArpConfigChain_Data_Helper10 */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgPool=MidiPkt_SetXferBlock_StyleImagePool */
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

/* cc900-name: MidiPkt_ArpCfgChain_Helper8=MidiPkt_ArpConfigChain_Data_Helper8 */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
void MidiPkt_ArpCfgChain_Helper8(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 7);
		MidiPkt_SetXferBlk_StyleImgHdr((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3612, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

/* cc900-name: MidiPkt_ArpCfgChain_Helper9=MidiPkt_ArpConfigChain_Data_Helper9 */
/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
void MidiPkt_ArpCfgChain_Helper9(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 8);
		MidiPkt_SetXferBlk_StyleImgTbl((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_361E, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_XferShowCompleted(void)
{
	GLOBAL_ERROR_CODE = 35;
	UI_InterruptTitleByIndex(TT_MESAGE);
}

/* cc900-name: MidiPkt_XferShowErrorMsg=MidiPkt_XferShowErrorMessage */
void MidiPkt_XferShowErrorMsg(void)
{
	GLOBAL_ERROR_CODE = MidiRx_PartLookup_ByteMap[SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4)];
	UI_InterruptTitleByIndex(TT_MESAGE);
}

void MidiPkt_XferShowNothing(void)
{
}

/* cc900-name: MidiPkt_XferShowErrorMsg=MidiPkt_XferShowErrorMessage */
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

void SysEx_SendAllData(void)
{
	ram_bd18 |= 0x08;
	MidiPkt_SetXferTotal_All((struct xfer *)0xbcbcL);
	MidiPkt_ArpConfigChain_Data();
	ram_bd18 &= ~0x08;
}

/* cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks */
/* cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
void SysEx_SendMspUserData(void)
{
	MidiPkt_SetXferTotal_AccompBlk((struct xfer *)0xbcbcL);
	MidiPkt_SendGrp_AccompBlocks();
}

void SysEx_SendNothing(void)
{
}

void SysEx_SendPanelMemoryData(void)
{
	MidiPkt_SetXferTotal_Panel((struct xfer *)0xbcbcL);
	MidiPkt_SendGroup_Panel();
}

/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
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

/* cc900-name: MidiPkt_SetXferTotal_StyleImg=MidiPkt_SetXferTotal_StyleImage */
void SysEx_SendStyleImageData(void)
{
	MidiPkt_SetXferTotal_StyleImg((struct xfer *)0xbcbcL);
	MidiPkt_SendGroup_StyleImage();
}

/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
/* cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks */
void MidiPkt_ArpConfigChain_Data(void)
{
	MidiPkt_SendGroup_Panel();
	MidiPkt_SendGroup_SoundRam();
	MidiPkt_SendGrp_AccompBlocks();
	MidiPkt_SendGroup_StyleImage();
	MidiPkt_ArpCfgChain_Join();
}

/* cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks */
/* cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks */
/* cc900-name: MidiPkt_SendBlk_AccompAreaHdr=MidiPkt_SendBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SendBlk_AccompBankTbls=MidiPkt_SendBlock_AccompBankTables */
/* cc900-name: MidiPkt_SendBlk_AccompBlockPool=MidiPkt_SendBlock_AccompBlockPool */
void MidiPkt_SendGrp_AccompBlocks(void)
{
	MidiPkt_SendBlk_AccompAreaHdr();
	MidiPkt_SendBlk_AccompBankTbls();
	MidiPkt_SendBlk_AccompBlockPool();
	MidiPkt_SendGroupEnd();
}

/* cc900-name: MidiPkt_SendBlk_PanelMemories=MidiPkt_SendBlock_PanelMemories */
void MidiPkt_SendGroup_Panel(void)
{
	MidiPkt_SendBlock_LivePanel();
	MidiPkt_SendBlk_PanelMemories();
	MidiPkt_SendGroupEnd();
}

void MidiPkt_SendGroup_SoundRam(void)
{
	if (AccWrap_ReturnZero(1) != -1) {
		MidiPkt_SendBlock_SoundRamId();
		MidiPkt_SendBlock_SoundRamData();
		MidiPkt_SendGroupEnd();
	}
}

/* cc900-name: MidiPkt_ArpCfgChain_Helper8=MidiPkt_ArpConfigChain_Data_Helper8 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper9=MidiPkt_ArpConfigChain_Data_Helper9 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper10=MidiPkt_ArpConfigChain_Data_Helper10 */
void MidiPkt_SendGroup_StyleImage(void)
{
	if (AccWrap_ReturnZero(3) != -1) {
		MidiPkt_ArpCfgChain_Helper8();
		MidiPkt_ArpCfgChain_Helper9();
		MidiPkt_ArpCfgChain_Helper10();
		MidiPkt_SendGroupEnd();
	}
}

/* cc900-name: MidiPkt_SendBlk_AccompAreaHdr=MidiPkt_SendBlock_AccompAreaHeader */
/* cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader */
void MidiPkt_SendBlk_AccompAreaHdr(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 18);
		MidiPkt_SetXferBlk_AccompArea((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3656, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

/* cc900-name: MidiPkt_SendBlk_AccompBankTbls=MidiPkt_SendBlock_AccompBankTables */
/* cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
void MidiPkt_SendBlk_AccompBankTbls(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 19);
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3662, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

/* cc900-name: MidiPkt_SendBlk_AccompBlockPool=MidiPkt_SendBlock_AccompBlockPool */
/* cc900-name: MidiPkt_SetXferBlk_AccompPool=MidiPkt_SetXferBlock_AccompBlockPool */
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

void MidiPkt_SendBlock_LivePanel(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 1);
		MidiPkt_SetXferBlock_LivePanel((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35E2, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

/* cc900-name: MidiPkt_SendBlk_PanelMemories=MidiPkt_SendBlock_PanelMemories */
void MidiPkt_SendBlk_PanelMemories(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 2);
		MidiPkt_SetXferBlock_PanelMemories((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35EE, 12);
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

void MidiPkt_SendBlock_SoundRamId(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 4);
		MidiPkt_SetXferBlock_SoundRamId((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35FA, 12);
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
