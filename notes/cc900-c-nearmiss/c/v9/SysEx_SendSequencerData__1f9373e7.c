/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/midi_dispatch_handlers_m286.c (2026-11-19-92-p6-r57)
   sha256 1f9373e79f12efdca5885479565839bb316abb0fe5a4af1cd75fe40c48008f08 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
struct xfer;
extern void MidiPkt_SetXferTotal_SeqData(struct xfer *);
extern void MidiPkt_ArpCfgChain_Join(void);
void SysEx_SendSequencerData(void)
{
	MidiPkt_SetXferTotal_SeqData((struct xfer *)0xbcbcL);
	MidiPkt_ArpCfgChain_Join();
}
