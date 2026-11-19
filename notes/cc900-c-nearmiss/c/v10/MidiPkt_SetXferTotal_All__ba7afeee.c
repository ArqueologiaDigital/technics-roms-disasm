/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_3m285b.c (2026-11-19-22-p6-r45)
   sha256 ba7afeee223584654daa5ded2a59e9bf4cdb3ff5c8d860a0acf5e437957a15f1 (tar-sha256); compiled at -O3 -Xr
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
	long m;
	long t;

	x->start = &LIVE_PANEL_BLOCK;
	n = MidiPkt_GetUsedSize_SeqEvents();
	m = MidiPkt_GetUsedSize_AccompBlocks();
	t = (&ram_ffbe - &LIVE_PANEL_BLOCK) + 0x12cb2;
	x->size += t + m + n + 0x5800;
	if (AccWrap_ReturnZero(1) != -1)
		x->size += 0x72aa;
	if (AccWrap_ReturnZero(3) != -1)
		x->size += MidiPkt_GetUsedSize_StyleImage();
	x->end = (unsigned char *)(x->size + (long)x->start);
}
