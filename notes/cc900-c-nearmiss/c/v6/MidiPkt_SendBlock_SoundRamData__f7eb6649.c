/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 f7eb66499474a04f412dbdbef754cb4ae464cbb012dcc216801816f1560c5a6c (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char *__near ram_bbf4;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(unsigned char *, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_ProcessAndSort_Data(void);
extern void MidiPkt_SetXferBlock_SoundRamData(struct xfer *);
extern unsigned char SysEx_TechMsg_3606[];
void MidiPkt_SendBlock_SoundRamData(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bbf4, 3, 5);
		MidiPkt_SetXferBlock_SoundRamData((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_3606, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}
