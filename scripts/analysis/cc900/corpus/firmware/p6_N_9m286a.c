/* lane_p6 helper N, round 9, form a: module 286 (midi/midi_dispatch_handlers.s), new functions: the
   MidiPkt_ArpConfigChain_Data_Helper8 .. 13 family and its Join.  Each helper, when field 4 of the active MIDI
   buffer is 0, reads channel parameter N, sets up one bulk-dump block of the transfer at 0xbccc (the built
   MidiPkt_SetXferBlock_* family; 0xbccc a numeric pointer, `ld xwa,imm`), queues the block's 9- or 12-byte SysEx
   header and processes the queue.  The body is written inside the `== 0` test, so the last call is the ROM's
   `call; ret`, not a tail jump.  The ROM's `ld xwa,imm` for 0xbccc suggests -Xr (both sets are compiled).
   cc900-options: -Xr
*/
/* cc900-module: MidiPkt_ArpConfigChain_Data_Helper11 MidiPkt_ArpConfigChain_Data_Helper12 MidiPkt_ArpConfigChain_Data_Helper13 MidiPkt_SendGroupEnd */
/* cc900-name: MidiPkt_ArpCfgChain_Helper8=MidiPkt_ArpConfigChain_Data_Helper8 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper9=MidiPkt_ArpConfigChain_Data_Helper9 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper10=MidiPkt_ArpConfigChain_Data_Helper10 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper11=MidiPkt_ArpConfigChain_Data_Helper11 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper12=MidiPkt_ArpConfigChain_Data_Helper12 */
/* cc900-name: MidiPkt_ArpCfgChain_Helper13=MidiPkt_ArpConfigChain_Data_Helper13 */
/* cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */

struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near ram_bcb4;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_Pack21BitValue(void);
extern void ArpQueue_ProcessAndSort_Data(void);
extern void MidiPkt_SetXferBlock_StyleImageHeader(struct xfer *);
extern void MidiPkt_SetXferBlock_StyleImageTables(struct xfer *);
extern void MidiPkt_SetXferBlock_StyleImagePool(struct xfer *);
extern void MidiPkt_SetXferBlock_CurrentSong(struct xfer *);
extern void MidiPkt_SetXferBlock_SongSlots(struct xfer *);
extern void MidiPkt_SetXferBlock_SeqEvents(struct xfer *);
extern unsigned char SysEx_TechMsg_3612[];
extern unsigned char SysEx_TechMsg_361E[];
extern unsigned char SysEx_TechMsg_362A[];
extern unsigned char SysEx_TechMsg_3634[];
extern unsigned char SysEx_TechMsg_3640[];
extern unsigned char SysEx_TechMsg_364C[];
extern int AccWrap_ReturnZero(int);
extern void MidiPkt_SendGroupEnd(void);
extern void MidiPkt_ArpCfgChain_Helper11(void);
extern void MidiPkt_ArpCfgChain_Helper12(void);
extern void MidiPkt_ArpCfgChain_Helper13(void);

void MidiPkt_ArpCfgChain_Helper8(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 7);
		MidiPkt_SetXferBlock_StyleImageHeader((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3612, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Helper9(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 8);
		MidiPkt_SetXferBlock_StyleImageTables((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_361E, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Helper10(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 9);
		MidiPkt_SetXferBlock_StyleImagePool((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_362A, 9);
		ArpQueue_Pack21BitValue();
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Join(void)
{
	if (AccWrap_ReturnZero(4) != -1) {
		MidiPkt_ArpCfgChain_Helper11();
		MidiPkt_ArpCfgChain_Helper12();
		MidiPkt_ArpCfgChain_Helper13();
		MidiPkt_SendGroupEnd();
	}
}

void MidiPkt_ArpCfgChain_Helper11(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 11);
		MidiPkt_SetXferBlock_CurrentSong((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3634, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Helper12(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 12);
		MidiPkt_SetXferBlock_SongSlots((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3640, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}

void MidiPkt_ArpCfgChain_Helper13(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 13);
		MidiPkt_SetXferBlock_SeqEvents((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_364C, 9);
		ArpQueue_Pack21BitValue();
		ArpQueue_ProcessAndSort_Data();
	}
}
