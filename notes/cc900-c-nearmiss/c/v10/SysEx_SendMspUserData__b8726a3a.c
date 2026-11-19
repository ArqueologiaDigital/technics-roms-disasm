/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m286a.c (2026-11-19-83-p6-r56)
   sha256 b8726a3a71982a43615d796ffa19dae43be9729704e50c7da2beb12b58280117 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr
   cc900-name: MidiPkt_SendGrp_AccompBlocks=MidiPkt_SendGroup_AccompBlocks
   cc900-name: MidiPkt_SetXferTotal_AccompBlk=MidiPkt_SetXferTotal_AccompBlocks */
struct xfer;
extern void MidiPkt_SetXferTotal_AccompBlk(struct xfer *);
extern void MidiPkt_SendGrp_AccompBlocks(void);
void SysEx_SendMspUserData(void)
{
	MidiPkt_SetXferTotal_AccompBlk((struct xfer *)0xbcbcL);
	MidiPkt_SendGrp_AccompBlocks();
}
