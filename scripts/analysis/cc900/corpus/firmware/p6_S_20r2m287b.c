/* Phase 6, lane_p6 helper S, round 2 of 2026-11-20, module 287 (midi/midi_dispatch_handlers.s), form b: first
   probes of the receive side left by helper N (p6_N_12m287a.c matched the XferOn* siblings at run r57).
   - MidiPkt_XferOnSeqEventBlock: p6_N_12m287a's MidiPkt_XferOnPanelMemBlock with block 13, the event block
     (MidiPkt_SetXferBlock_SeqEvents) and the length from the message (MidiPkt_SetXferLengthFromMsg); error 28.
   - MidiPkt_XferOnDataPacket / MidiPkt_XferOnGroupEnd: field 3 of the spare buffer (< 22) indexes the 22-entry
     handler tables SeqChan_StepCmdHandlers / SeqChan_WriteFieldHandlers (call through, then ret; GroupEnd then
     clears bit 7 of 0xbd1c).  DataPacket reads the field with SeqData_ReadFieldByIndex, GroupEnd directly (+3).
   - the steppers SeqChan_StepCmd_* / SeqChan_XferStep_*: set receive state N (field 3), unpack the packet
     (MidiPkt_UnpackNibblesToXfer; Field5to6 also TmFlash_BulkTransferToSubCPU; CurrentSong / SongSlots /
     Field13Write only when AccWrap_ReturnZero(4) != 0xffff, the ROM's `call nz`), and when field 15 reads 0 set
     state N + 1: a call that ends an `if` without else (the ROM's call + ret).
   - SeqChan_ProcessStepCmd / SeqChan_DefaultHandler: error 19 / 31 (tail jump); SeqChan_WriteField_Data_A..E:
     state 0, then set bit 7 / 6 / 5 / 4 / 2 of MIDIPKT_RX_GROUPS (0xbd1a).
   Form b: GroupEnd's table index read in the subscript (no local; DataPacket keeps its local, the
   ROM calls once); each stepper's last call after an early return, `if (... != 0) return;` (form a:
   inside `if (... == 0)`).
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqChan_StepCmd_Field13Write */
/* cc900-name: MidiPkt_SetXferBlk_SeqEvents=MidiPkt_SetXferBlock_SeqEvents */
/* cc900-name: SeqChan_XferStep_StyleImageBlk1=SeqChan_XferStep_StyleImageBlock1 */

struct mq;
typedef struct mq *mqp;
struct xfer;
typedef void (*cmdfn)(void);
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char __near ram_bd1c;
extern unsigned char __near MIDIPKT_RX_GROUPS;
extern cmdfn SeqChan_StepCmdHandlers[];
extern cmdfn SeqChan_WriteFieldHandlers[];
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern int AccWrap_ReturnZero(int);
extern void MidiPkt_UnpackNibblesToXfer(void);
extern void TmFlash_BulkTransferToSubCPU(void);
extern void MidiPkt_SetXferLengthFromMsg(void);
extern void MidiPkt_SetXferBlk_SeqEvents(struct xfer *);
extern void SeqChan_StepCmd_Field13Write(void);

void MidiPkt_XferOnSeqEventBlock(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 13) {
		MidiPkt_SetXferBlk_SeqEvents((struct xfer *)0xbcecL);
		MidiPkt_SetXferLengthFromMsg();
		SeqChan_StepCmd_Field13Write();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 28);
}

void MidiPkt_XferOnDataPacket(void)
{
	unsigned char n;

	n = SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3);
	if (n < 22)
		SeqChan_StepCmdHandlers[n]();
}

void SeqChan_ProcessStepCmd(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 19);
}

void SeqChan_StepCmd_Field1to2(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 1);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 2);
}

void SeqChan_StepCmd_Field2to3(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 2);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 3);
}

void SeqChan_StepCmd_Field4to5(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 4);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 5);
}

void SeqChan_StepCmd_Field5to6(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 5);
	MidiPkt_UnpackNibblesToXfer();
	TmFlash_BulkTransferToSubCPU();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 6);
}

void SeqChan_XferStep_StyleImageBlk1(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 7);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 8);
}

void SeqChan_StepCmd_Field8to9(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 8);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 9);
}

void SeqChan_StepCmd_Field9to10(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 9);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 10);
}

void SeqChan_XferStep_AccompBlock1(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 18);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 19);
}

void SeqChan_XferStep_AccompBlock2(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 19);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 20);
}

void SeqChan_StepCmd_Field20to21(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 20);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 21);
}

void SeqChan_XferStep_CurrentSong(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 11);
	if (AccWrap_ReturnZero(4) != 0xffff)
		MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 12);
}

void SeqChan_XferStep_SongSlots(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 12);
	if (AccWrap_ReturnZero(4) != 0xffff)
		MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 13);
}

void SeqChan_StepCmd_Field13Write(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 13);
	if (AccWrap_ReturnZero(4) != 0xffff)
		MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 14);
}

void MidiPkt_XferOnGroupEnd(void)
{
	if (((unsigned char *)MIDISEQ_SPARE_BUF_PTR)[3] < 22) {
		SeqChan_WriteFieldHandlers[((unsigned char *)MIDISEQ_SPARE_BUF_PTR)[3]]();
		ram_bd1c &= ~0x80;
	}
}

void SeqChan_DefaultHandler(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 31);
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
