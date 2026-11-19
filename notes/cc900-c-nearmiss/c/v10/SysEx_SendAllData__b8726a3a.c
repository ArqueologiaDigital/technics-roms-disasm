/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_11m286a.c (2026-11-19-83-p6-r56)
   sha256 b8726a3a71982a43615d796ffa19dae43be9729704e50c7da2beb12b58280117 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct xfer;
extern unsigned char __near ram_bd18;
extern void MidiPkt_SetXferTotal_All(struct xfer *);
extern void MidiPkt_ArpConfigChain_Data(void);
void SysEx_SendAllData(void)
{
	ram_bd18 |= 0x08;
	MidiPkt_SetXferTotal_All((struct xfer *)0xbcbcL);
	MidiPkt_ArpConfigChain_Data();
	ram_bd18 &= ~0x08;
}
