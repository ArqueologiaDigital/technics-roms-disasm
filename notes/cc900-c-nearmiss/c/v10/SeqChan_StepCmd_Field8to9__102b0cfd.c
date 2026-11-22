/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_20r2m287b.c (2026-11-21-5-p6-r60)
   sha256 102b0cfd6c654432c5507cc96c8d0ac7d3f128e0f979e4951c82467ca5a3e9c2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_UnpackNibblesToXfer(void);
void SeqChan_StepCmd_Field8to9(void)
{
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 8);
	MidiPkt_UnpackNibblesToXfer();
	if (SeqData_ReadFieldByIndex(MIDISEQ_ACTIVE_BUF_PTR, 15) != 0)
		return;
	MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 3, 9);
}
