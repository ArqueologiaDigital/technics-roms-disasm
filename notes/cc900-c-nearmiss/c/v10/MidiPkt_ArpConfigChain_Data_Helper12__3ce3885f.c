/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers_m286_b.c (2026-11-19-92-p6-r57)
   sha256 3ce3885f576bccc7f3e034e4b5ed4f6aebabe7d47fd813e105ab69405ec17cb6 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_ArpCfgChain_Helper12=MidiPkt_ArpConfigChain_Data_Helper12 */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near ram_bcb4;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_ProcessAndSort_Data(void);
extern void MidiPkt_SetXferBlock_SongSlots(struct xfer *);
extern unsigned char SysEx_TechMsg_3640[];
void MidiPkt_ArpCfgChain_Helper12(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 12);
		MidiPkt_SetXferBlock_SongSlots((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3640, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}
