/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m287a.c (2026-11-19-92-p6-r57)
   sha256 d0dd4b54cb317f57198717be27865010ea5a745471c4975fd1a1b159ec39d424 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
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
