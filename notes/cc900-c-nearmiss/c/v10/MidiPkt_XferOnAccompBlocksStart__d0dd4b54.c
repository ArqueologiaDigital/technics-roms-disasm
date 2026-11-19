/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m287a.c (2026-11-19-92-p6-r57)
   sha256 d0dd4b54cb317f57198717be27865010ea5a745471c4975fd1a1b159ec39d424 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr
   cc900-name: MidiPkt_PrepAccompBlocksReceive=MidiPkt_PrepareAccompBlocksReceive
   cc900-name: MidiPkt_SetXferBlk_AccompArea=MidiPkt_SetXferBlock_AccompAreaHeader
   cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_PrepAccompBlocksReceive(void);
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *);
extern void MidiPkt_SetXferBlk_AccompArea(struct xfer *);
extern void SeqChan_XferStep_AccompBlock1(void);
void MidiPkt_XferOnAccompBlocksStart(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 0) {
		MidiPkt_PrepAccompBlocksReceive();
		MidiPkt_SetXferTotal_AccompBlk((struct xfer *)0xbcdcL);
		MidiPkt_SetXferBlk_AccompArea((struct xfer *)0xbcecL);
		SeqChan_XferStep_AccompBlock1();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
}
