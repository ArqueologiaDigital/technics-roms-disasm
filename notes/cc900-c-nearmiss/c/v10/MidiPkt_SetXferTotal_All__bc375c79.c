/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m285b.c (2026-11-19-15-p6-r42)
   sha256 bc375c79d4549f87a4f43309c1f3e1d7f2271396294ada251df5827b155332b6 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct xfer { unsigned char *start; unsigned char *end; long size; };
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern long MidiPkt_GetUsedSize_SeqEvents(void);
extern long MidiPkt_GetUsedSize_AccompBlocks(void);
extern long MidiPkt_GetUsedSize_StyleImage(void);
extern int AccWrap_ReturnZero(int);
void MidiPkt_SetXferTotal_All(struct xfer *x)
{
	long n;

	x->start = &LIVE_PANEL_BLOCK;
	n = MidiPkt_GetUsedSize_SeqEvents();
	x->size += &ram_ffbe - &LIVE_PANEL_BLOCK + 0x12cb2 + MidiPkt_GetUsedSize_AccompBlocks() + n + 0x5800;
	if (AccWrap_ReturnZero(1) != -1)
		x->size += 0x72aa;
	if (AccWrap_ReturnZero(3) != -1)
		x->size += MidiPkt_GetUsedSize_StyleImage();
	x->end = x->size + x->start;
}
