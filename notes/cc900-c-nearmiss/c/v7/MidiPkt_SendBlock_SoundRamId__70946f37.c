/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 70946f375194e4553de5aa2408bf7bca4fc8c361e17088ad61466f276943f5b4 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char *__near ram_bc18;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(unsigned char *, int, int);
extern void SeqBuf_FlushNoteOffs(unsigned char *, unsigned int);
extern void ArpQueue_ProcessAndSort_Data(void);
extern void MidiPkt_SetXferBlock_SoundRamId(struct xfer *);
extern unsigned char SysEx_TechMsg_35FA[];
void MidiPkt_SendBlock_SoundRamId(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 4) == 0) {
		MIDI_ReadChannelParam(ram_bc18, 3, 4);
		MidiPkt_SetXferBlock_SoundRamId((struct xfer *)0xbcccL);
		SeqBuf_FlushNoteOffs(SysEx_TechMsg_35FA, 12);
		ArpQueue_ProcessAndSort_Data();
	}
}
