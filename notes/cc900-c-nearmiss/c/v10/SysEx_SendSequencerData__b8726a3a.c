/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m286a.c (2026-11-19-83-p6-r56)
   sha256 b8726a3a71982a43615d796ffa19dae43be9729704e50c7da2beb12b58280117 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr
   cc900-name: MidiPkt_ArpCfgChain_Join=MidiPkt_ArpConfigChain_Data_Join */
struct xfer;
extern void MidiPkt_SetXferTotal_SeqData(struct xfer *);
extern void MidiPkt_ArpCfgChain_Join(void);
void SysEx_SendSequencerData(void)
{
	MidiPkt_SetXferTotal_SeqData((struct xfer *)0xbcbcL);
	MidiPkt_ArpCfgChain_Join();
}
