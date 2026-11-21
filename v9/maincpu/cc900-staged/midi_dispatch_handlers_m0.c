/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqChan_StepCmd_Field13Write */   /* scripts/analysis/cc900/module_calls.py v10 */

struct mq;
typedef struct mq *mqp;
typedef void (*cmdfn)(void);
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern cmdfn SeqChan_StepCmdHandlers[];
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MidiPkt_XferOnDataPacket(void);
extern unsigned char __near ram_bd1c;
extern cmdfn SeqChan_WriteFieldHandlers[];
extern void MidiPkt_XferOnGroupEnd(void);
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_SetXferLengthFromMsg(void);
extern void MidiPkt_SetXferBlk_SeqEvents(struct xfer *);
extern void SeqChan_StepCmd_Field13Write(void);
extern void MidiPkt_XferOnSeqEventBlock(void);
extern void SeqChan_DefaultHandler(void);
extern void SeqChan_ProcessStepCmd(void);
extern int AccWrap_ReturnZero(int);
extern void MidiPkt_UnpackNibblesToXfer(void);
extern void SeqChan_StepCmd_Field1to2(void);
extern void SeqChan_StepCmd_Field20to21(void);
extern void SeqChan_StepCmd_Field2to3(void);
extern void SeqChan_StepCmd_Field4to5(void);
extern void TmFlash_BulkTransferToSubCPU(void);
extern void SeqChan_StepCmd_Field5to6(void);
extern void SeqChan_StepCmd_Field8to9(void);
extern void SeqChan_StepCmd_Field9to10(void);
extern unsigned char __near MIDIPKT_RX_GROUPS;
extern void SeqChan_WriteField_Data_A(void);
extern void SeqChan_WriteField_Data_B(void);
extern void SeqChan_WriteField_Data_C(void);
extern void SeqChan_WriteField_Data_D(void);
extern void SeqChan_WriteField_Data_E(void);
extern void SeqChan_XferStep_AccompBlock1(void);
extern void SeqChan_XferStep_AccompBlock2(void);
extern void SeqChan_XferStep_CurrentSong(void);
extern void SeqChan_XferStep_SongSlots(void);
extern void SeqChan_XferStep_StyleImageBlk1(void);

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
