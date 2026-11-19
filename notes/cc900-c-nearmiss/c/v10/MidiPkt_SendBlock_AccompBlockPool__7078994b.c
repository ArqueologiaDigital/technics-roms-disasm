/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_10m286a.c (2026-11-19-76-p6-r55)
   sha256 7078994bc8d5ea567e3965fcd1602e028f6c96eaf52924812658af3cc5f58202 (tar-sha256); compiled at -Xr
   cc900-options: -Xr
   cc900-name: MidiPkt_SendBlk_AccompBlockPool=MidiPkt_SendBlock_AccompBlockPool
   cc900-name: MidiPkt_SetXferBlk_AccompPool=MidiPkt_SetXferBlock_AccompBlockPool */
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
extern void MidiPkt_SetXferBlk_AccompPool(struct xfer *);
extern unsigned char SysEx_TechMsg_366E[];
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
