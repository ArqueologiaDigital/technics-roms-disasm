/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/midi_dispatch_handlers_m0.c (2026-11-21-2-p6-r58)
   sha256 0ab9b7f47af9ecea31b3921f8ec6fdaedca05703994ce960b227acf3b79031ea (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_SetXferBlk_StyleImgPool=MidiPkt_SetXferBlock_StyleImagePool */
struct mq;
typedef struct mq *mqp;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
struct xfer;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_SetXferLengthFromMsg(void);
extern void MidiPkt_SetXferBlk_StyleImgPool(struct xfer *);
extern void SeqChan_StepCmd_Field9to10(void);
void MidiPkt_ArpExtHandler_G(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 9) {
		MidiPkt_SetXferBlk_StyleImgPool((struct xfer *)0xbcecL);
		MidiPkt_SetXferLengthFromMsg();
		SeqChan_StepCmd_Field9to10();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 27);
}
