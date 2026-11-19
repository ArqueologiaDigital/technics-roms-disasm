/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m285a.c (2026-11-19-22-p6-r45)
   sha256 7211ca892a00d695fd158ef5436905b06bbdbaf111c3aa90d685921faaa82005 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern unsigned long MidiPkt_GetUsedSize_SeqEvents(void);
extern unsigned long MidiPkt_GetUsedSize_AccompBlocks(void);
extern unsigned long MidiPkt_GetUsedSize_StyleImage(void);
extern int AccWrap_ReturnZero(int);
void MidiPkt_SetXferTotal_All(struct xfer *x)
{
	unsigned long n;

	x->start = &LIVE_PANEL_BLOCK;
	n = MidiPkt_GetUsedSize_SeqEvents();
	x->size += (&ram_ffbe - &LIVE_PANEL_BLOCK) + 0x12cb2 + MidiPkt_GetUsedSize_AccompBlocks() + n + 0x5800;
	if (AccWrap_ReturnZero(1) != -1)
		x->size += 0x72aa;
	if (AccWrap_ReturnZero(3) != -1)
		x->size += MidiPkt_GetUsedSize_StyleImage();
	x->end = (unsigned char *)(x->size + (long)x->start);
}
