/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/midi_dispatch_handlers_m0.c (2026-11-21-2-p6-r58)
   sha256 5808451f3a4d1ced9a51c13601d75f49d8ae0ae57064fe9c1baf1d7c9b9b125a (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
struct xfer;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_PreparePanelReceive(void);
extern void MidiPkt_SetXferTotal_Panel(struct xfer *);
extern void MidiPkt_SetXferBlock_LivePanel(struct xfer *);
extern void SeqChan_StepCmd_Field1to2(void);
void MidiPkt_ArpExtHandler_A(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 0) {
		MidiPkt_PreparePanelReceive();
		MidiPkt_SetXferTotal_Panel((struct xfer *)0xbcdcL);
		MidiPkt_SetXferBlock_LivePanel((struct xfer *)0xbcecL);
		SeqChan_StepCmd_Field1to2();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 25);
}
