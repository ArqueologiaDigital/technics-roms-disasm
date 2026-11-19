/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_12m287a.c (2026-11-19-92-p6-r57)
   sha256 d0dd4b54cb317f57198717be27865010ea5a745471c4975fd1a1b159ec39d424 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr
   cc900-name: MidiPkt_SetXferBlk_AccompBank=MidiPkt_SetXferBlock_AccompBankTables
   cc900-name: MidiPkt_XferOnAccompBlocksBlk2=MidiPkt_XferOnAccompBlocksBlock2 */
struct mq;
typedef struct mq *mqp;
struct xfer;
extern mqp __near MIDISEQ_ACTIVE_BUF_PTR;
extern mqp __near MIDISEQ_SPARE_BUF_PTR;
extern unsigned char SeqData_ReadFieldByIndex(mqp, unsigned int);
extern void MIDI_ReadChannelParam(mqp, int, int);
extern void MidiPkt_SetXferBlk_AccompBank(struct xfer *);
extern void SeqChan_XferStep_AccompBlock2(void);
void MidiPkt_XferOnAccompBlocksBlk2(void)
{
	if (SeqData_ReadFieldByIndex(MIDISEQ_SPARE_BUF_PTR, 3) == 19) {
		MidiPkt_SetXferBlk_AccompBank((struct xfer *)0xbcecL);
		SeqChan_XferStep_AccompBlock2();
	} else
		MIDI_ReadChannelParam(MIDISEQ_ACTIVE_BUF_PTR, 4, 30);
}
