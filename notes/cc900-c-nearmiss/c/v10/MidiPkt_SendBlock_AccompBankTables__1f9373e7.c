/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 1f9373e79f12efdca5885479565839bb316abb0fe5a4af1cd75fe40c48008f08 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SendBlk_AccompBankTbls=MidiPkt_SendBlock_AccompBankTables
   cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char *__near ram_bcb4;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(unsigned char *, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_ProcessAndSort_Data(void);
extern void MidiPkt_SetXferBlk_AccompBank(struct xfer *);
extern unsigned char SysEx_TechMsg_3662[];
void MidiPkt_SendBlk_AccompBankTbls(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bcb4, 3, 19);
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3662, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}
